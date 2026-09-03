# OpenCode Bootstrap Prompt — {{ProjectName}}

You are working inside the {{ProjectName}} workspace.  
All specifications are located in `/Specs`, organized by domain.

Your job is to:
1. Read all Markdown files in `/Specs`
2. Build a complete understanding of the project
3. Follow the architecture, rules, and API definitions exactly
4. Generate code, tests, and project structure according to the specs
5. Ask for clarification only when absolutely necessary

When generating code:
- Follow the coding conventions in `/Specs/CodingConventions.md`
- Follow the ViewModel contracts in `/Specs/ViewModelContracts.md`
- Follow the UI interaction rules in `/Specs/UIInteractionRules.md`
- Follow the CloudKit schema in `/Specs/Cloud/CloudKitSchema.md`
- Follow the engine specs in `/Specs/Engine/*`
- Follow the architecture in `/Specs/Architecture/SwiftUIArchitecture.md`

When unsure:
- Prefer the PDD
- Prefer the architecture docs
- Prefer the API reference

Start by summarizing your understanding of the project based on the specs.
