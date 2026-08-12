# Uncomment the following line to profile zsh
# zprof
alias altest="FIRESTORE_EMULATOR_HOST=127.0.0.1:8457 GCLOUD_PROJECT=pseudo-foobar PGHOST=127.0.0.1 PGUSER=postgres PGPASSWORD=postgres pnpm test"
alias alwatch="FIRESTORE_EMULATOR_HOST=127.0.0.1:8457 GCLOUD_PROJECT=pseudo-foobar PGHOST=127.0.0.1 PGUSER=postgres PGPASSWORD=postgres pnpm test:watch"

# About Google Cloud SDK - place google-cloud-sdk in $HOME/.google-cloud-sdk
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/.google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/.google-cloud-sdk/completion.zsh.inc"; fi
 
# Load Secret API key from credentials file if present
if [ -f "$HOME/.config/secrets/credentials.sh" ]; then
  source "$HOME/.config/secrets/credentials.sh"
fi

