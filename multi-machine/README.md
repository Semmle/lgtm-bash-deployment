

# Cluster configuration

As for the [single-machine installation](../single-machine), you must
first create a cluster configuration file and associated manifest. As
this is more complicated for a cluster, we suggest that you [read the
documentation](https://help.semmle.com/lgtm-enterprise/admin/help/sys-admin/lgtm-cluster-config.html)
for guidelines on how to go about doing this. We then assume that you
will be using a `state` directory stored in version control,
containing at least these files, along with any other supporting files
such as SSL certificates and an LGTM external provider configuration. 
Be aware that if you store sensitive data (for example, LGTM's `manifest.xml`) 
in version control, it should be encrypted and then decrypted on use, 
or the repository should be carefully protected from unauthorized access.

```shellsession
state/
├── lgtm-cluster-config.yml
└── manifest.xml
```

# Deployment

To deploy from a machine with SSH access to all hosts mentioned in
your cluster configuration file, simply checkout the `state` directory
alongside an untarred LGTM installation bundle and the
`deploy-multi.sh` script found next to this `README`:

```shellsession
.
├── deploy-multi.sh
├── lgtm-<version>
├── lgtm-<version>-<platform>.tar.gz
└── state
    ├── lgtm-cluster-config.yml
    └── manifest.xml
```

Then run the deploy script:

```shellsession
LGTM_CREDENTIALS_PASSWORD=<manifest password> ./deploy-multi.sh <lgtm directory>
```

# Post-installation configuration

Simple steps for post-installation configuration can be found in the
[single-machine deploy README](../single-machine/README.md).

