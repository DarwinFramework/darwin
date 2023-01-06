# Contributing to Darwin
Note that this file is currently not finished and will also change as the
framework changes and evolves. 

## Requirements
- Git (version control)
- Dart (development kit)
- IDE (i.E. AndroidStudio, IntelliJ or VS Code)

## Setup your Dev Environment
1. Fork the repository `https://github.com/DarwinFramework/darwin` and create
your branch from main
2. Pull the codebase from your fork
`git clone git@github.com:<user_name>/darwin.git`
3. if not already done. Add the main repository as upstream, so you can fetch
   and pull new changes
`git remote add upstream git@github.com:DarwinFramework/darwin.git`
4. [Install the melos-cli](https://melos.invertase.dev/getting-started) to help
   you interact with the monorepo and internal dependencies.
5. Bootstrap the project using `melos bootstrap`

## Performing and Committing Changes
1. Add your changes to the codebase and test it locally
2. Add tests to verify your additions where possible
3. Write a matching commit message following the
[Conventional Commits specs](https://www.conventionalcommits.org/en/v1.0.0/)
4. Push your changes to a new branch of your fork following the pattern
`git push origin <user_name>.<feature>`.  
(Replace origin if you use another remote)
5. Open up a pull request with your fork and an explanation of your changes.
Note that the title should also follow Conventional Commits and please enable
**"Allow edits by maintainers"**, to help us keep our sanity :)