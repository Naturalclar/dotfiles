# Ruby

## bundler

alias be="bundle exec"

## DevContainer

alias dcup="devcontainer up --workspace-folder=."
alias dcexec="devcontainer exec --workspace-folder=."

# JavaScript

## yarn
alias y="yarn"
alias yb="yarn build"
alias ys="yarn start"
alias yl="yarn lint"
alias ytc="yarn type-check"
alias build="yarn build"
alias start="yarn start"
alias ybuild="yarn build"
alias ystart="yarn start"
alias ylint="yarn lint"
alias bootstrap="yarn bootstrap"
alias ybt="yarn bootstrap"
alias yarnstrap="yarn bootstrap"
alias yw="yarn watch"
alias ytest="yarn test"
alias yyb="yarn && yarn bootstrap"
yalias() { alias | grep 'yarn'; }

## pnpm
alias p="pnpm"
alias pb="pnpm build"
alias ph="pnpm start"
alias pi="pnpm install"
alias add="pnpm add"
alias addd="pnpm add -D"
alias addg="pnpm global add"
alias lint="pnpm lint"
alias format="pnpm format"
alias tc="pnpm type-check"
alias type-check="yarn type-check"
alias ptc="pnpm type:check"

# github cli
alias getpr="gh pr checkout"
alias repo="gh repo create --public"
alias ghview="gh repo view -w"
alias makepr="gh pr create"
alias fork="gh repo fork"
alias gpc="gh pr create"

# npx
alias upset="npx git-upstream --set"

# ghq
alias get="ghq get"
## TODO: get used to working with github workspace to fully migrate to bare repo clones
alias getb="ghq get --bare"

# rimraf
alias rimraf="rm -rf"

