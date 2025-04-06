# CI/CD Pipeline Documentation

## MegaLinter Jenkins Pipeline

This directory contains Jenkins pipeline definitions for the repository, including the MegaLinter pipeline for code quality checking.

### MegaLinter Pipeline

The `megalinter.jenkinsfile` contains a pipeline definition that uses [MegaLinter](https://megalinter.io/) to check the entire codebase for quality issues.

#### Features

- Lints all supported files in the repository
- Generates detailed reports in HTML and other formats
- Can be configured to auto-fix certain issues
- Customizable through `.mega-linter.yml` in the repository root

#### Usage

1. Create a new Jenkins pipeline job
2. Set it to use SCM for the pipeline definition
3. Point it to this repository and specify the path `cicd/megalinter.jenkinsfile`
4. Trigger it manually or set up webhooks for automatic execution

#### Testing with CLI

You can test the MegaLinter pipeline locally before committing changes by using the test script:

```bash
# Navigate to the root of the repository
cd /path/to/repo

# Run the script
./cicd/pipeline_tester/run_megalinter.sh
```

This script will:
- Connect to your Jenkins instance using CLI credentials
- Create or update a job with the MegaLinter pipeline
- Run the job and show the output
- Provide useful commands for further job management

#### Configuration

The pipeline uses a `.mega-linter.yml` file in the repository root for configuration. You can customize:

- Which linters to run
- Which files to include/exclude
- Whether to apply automatic fixes
- Output formats

See the [MegaLinter documentation](https://megalinter.io/configuration/) for all configuration options.

#### Requirements

- Jenkins with Docker support
- The `publishHTML` plugin for publishing reports 