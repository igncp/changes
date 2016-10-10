# Ch-Ch-Ch-Ch-Changes

Modifications in popular / interesting repositories saved as diff files which can be applied with git.

To try them:
- Install Vagrant and clone the repository
- `cd` to a project directory and `vagrant up`
- Once the VM is provisioned: `vagrant ssh`
- Then you will be inside the VM. You can `cd ~/repository` and apply changes.
- For example: `git apply ~/src/lanaguage/project/changes1/diff.diff`

There are helper commands defined in the `~/.bashrc`:
- To reset to the original state of the repository
- To generate a diff from the changes in the repository
- To apply git changes in the repository from an existing diff
- To update the `src` files in the host with the ones in the VM

## License
MIT
