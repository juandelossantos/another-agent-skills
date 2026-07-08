# CLI Patterns by Language

## Node.js (commander + clack)

```typescript
import { Command } from 'commander';
import { intro, outro, spinner, isCancel } from '@clack/prompts';

const program = new Command();
program
  .name('mycli')
  .description('Does useful things')
  .option('-d, --debug', 'verbose output')
  .argument('<input>', 'input file')
  .action(async (input, options) => {
    intro('mycli');
    const s = spinner();
    s.start('Processing');
    await process(input);
    s.stop('Done');
    outro('Complete');
  });

program.parse();
```

## Python (click)

```python
import click

@click.command()
@click.argument('input')
@click.option('--output', '-o', help='Output file')
@click.option('--verbose', '-v', is_flag=True)
def cli(input, output, verbose):
    """Process INPUT file."""
    click.echo(f'Processing {input}')

if __name__ == '__main__':
    cli()
```

## Rust (clap)

```rust
use clap::Parser;

#[derive(Parser)]
#[command(name = "mycli")]
struct Cli {
    input: String,
    #[arg(short, long)]
    output: Option<String>,
}

fn main() {
    let cli = Cli::parse();
    println!("Processing {}", cli.input);
}
```

## Go (cobra)

```go
var rootCmd = &cobra.Command{
    Use:   "mycli",
    Short: "Does useful things",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("Processing")
    },
}

func main() {
    rootCmd.Execute()
}
```
