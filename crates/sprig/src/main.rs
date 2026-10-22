fn main() {
    if let Err(e) = dispatch() {
        eprintln!("{e}");
        std::process::exit(1);
    }
}

fn dispatch() -> Result<(), String> {
    let argv0 = std::env::args().next().unwrap_or_default();
    let cmd = std::path::Path::new(&argv0)
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("")
        .to_ascii_lowercase();

    match cmd.as_str() {
        "corevia-talk-acp" | "git-credential-nostr" | "git-sign-nostr" => {
            corevia_talk_acp::run().map_err(|e| e.to_string())
        }
        "corevia-talk-agent" => corevia_talk_agent::run().map_err(|e| e.to_string()),
        "sprig" => match std::env::args().nth(1).as_deref() {
            Some("-V") | Some("--version") => {
                println!("sprig {}", env!("CARGO_PKG_VERSION"));
                Ok(())
            }
            Some("-h") | Some("--help") | None => {
                print_usage();
                if std::env::args().len() <= 1 {
                    Err("error: invoke Sprig via a personality symlink".into())
                } else {
                    Ok(())
                }
            }
            Some(other) => {
                print_usage();
                Err(format!(
                    "error: unknown Sprig option or personality: {other}"
                ))
            }
        },
        // corevia-talk-dev-mcp handles its utility multicall names: rg, tree, corevia-talk.
        _ => corevia_talk_dev_mcp::run().map_err(|e| e.to_string()),
    }
}

fn print_usage() {
    println!(
        "Sprig — all-in-one Corevia Talk ACP harness, agent, and developer MCP\n\n\
Sprig is a multicall binary. Invoke it through one of the personality names:\n\n\
  corevia-talk-acp       ACP harness\n  corevia-talk-agent     ACP-compliant agent\n  corevia-talk-dev-mcp   Developer MCP server\n\n\
Helper names are also supported: rg, tree, corevia-talk, git-credential-nostr, git-sign-nostr.\n\n\
Installers can create links with:\n  ln -s sprig corevia-talk-acp\n  ln -s sprig corevia-talk-agent\n  ln -s sprig corevia-talk-dev-mcp"
    );
}
