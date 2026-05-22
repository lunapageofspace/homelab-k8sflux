set export
export CLUSTER := "testing"

[group: "Bootstrap"]
mod bootstrap "bootstrap"

[private]
default:
    just -l k8s testing