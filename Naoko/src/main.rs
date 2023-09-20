#[macro_use] extern crate serde;
#[macro_use] extern crate anyhow;

mod options;
mod kafka;

use env_logger::Env;

#[tokio::main(worker_threads=8)]
async fn main() -> anyhow::Result<()> {
  env_logger::Builder
            ::from_env(
              Env::default().default_filter_or("info")
            ).init();

  let iopts =
    options::get_ioptions()
           .map_err(|e| anyhow!("Failed to parse Dhall config {e}"))?;

  kafka::run_with_workers(1, iopts);

  tokio::signal::ctrl_c().await?;

  Ok(())
}
