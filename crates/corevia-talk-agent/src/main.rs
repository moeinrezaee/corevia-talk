fn main() {
    if let Err(e) = corevia_talk_agent::run() {
        eprintln!("Error: {e}");
        std::process::exit(1);
    }
}
