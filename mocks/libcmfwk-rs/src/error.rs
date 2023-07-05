pub enum Error {
    Fail,
}

pub type Result<T = ()> = std::result::Result<T, Error>;
