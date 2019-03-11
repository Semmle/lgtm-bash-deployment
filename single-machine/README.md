

# Cluster configuration

For a fresh installation, run the following commands to create a
simple cluster configuration file, placing all components on this
machine:

```shellsession
java -jar <path to config gen>/lgtm-config-gen.jar init
LGTM_CREDENTIALS_PASSWORD=password java -jar <path to config gen>/lgtm-config-gen.jar generate
```

At this point, the resulting `state` directory contains the two files
that describe how to deploy an LGTM installation:

```shellsession
state/
├── lgtm-cluster-config.yml
└── manifest.xml
```

We suggest that you store these files in version control. You can also
modify the cluster configuration file, for example to specify another
external URL, or to add an SSL certificate. You can find more
information [in the LGTM administrator
help](https://help.semmle.com/lgtm-enterprise/admin/help/sys-admin/lgtm-cluster-config.html).


# Deployment

To deploy, simply checkout the `state` directory onto the target
machine alongside an untarred LGTM installation bundle and the
`deploy-single.sh` script found next to this `README`:

```shellsession
.
├── deploy-single.sh
├── lgtm-1.20.0
├── lgtm-1.20.0.tar.gz
└── state
    ├── lgtm-cluster-config.yml
    └── manifest.xml
```

Then run the deploy script:

```shellsession
LGTM_CREDENTIALS_PASSWORD=<manifest password> ./deploy-single.sh <lgtm directory>
```

# Post-installation configuration

Before using a fresh installation, or if you have received a new
license file, upload it either from the administration interface or
using the CLI as follows:

```shellsession
sudo lgtm-cli license --install <path to license file>
```

Create an administrator account to get logged in and complete any
further configuration or start using the site:

```shellsession
sudo lgtm-cli create-user --email admin@example.com --password <password> --display-name Administrator
sudo lgtm-cli grant-admin --name admin@example.com
```

