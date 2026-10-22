#[tokio::main]
async fn main() {
    std::process::exit(corevia_talk_cli::run_from_args(std::env::args()).await);
}
