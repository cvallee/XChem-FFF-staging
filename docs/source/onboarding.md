# Onboarding

This page guides new users through the steps required to access the IRIS compute cluster at Diamond Light Source (DLS) and to access Squonk in order to run the FFF pipeline. At the end of this page you will be directed to the [Setup](setup.md) instructions to install the pipeline tools.

```{note}
If you run into problems during onboarding, the most common issues are access and password-related and depend on your user type. See the table below to find the right support route.
```

---

## Step 1 — Generate a FedID

A **FedID** is your Diamond Light Source federated identity — the username and password used to log in to all DLS systems, including IRIS.

1. Register an account on UAS at [https://uas.diamond.ac.uk](https://uas.diamond.ac.uk)
Confirm you are named on an open or active proposal at [https://uas.diamond.ac.uk](https://uas.diamond.ac.uk). If your proposal is not active, you will not be able to authenticate against DLS systems. To be added to a proposal, contact the FFF-coordinator. 
2. If you are a **Beamtime User** and do not yet have a FedID, contact the DLS User Office (USEROFFICE@diamond.ac.uk) who will issue one as part of visit registration.
3. If you are a **Visiting Scientist or Contractor** and need a password reset or account unlock, contact the Diamond IT Helpdesk (ITSupport@diamond.ac.uk).

```{note}
Reference documents covering IRIS access, the XChem GPFS data policy, remote connection setup, and SSH key configuration are available from the FFF-coordinator.
```

---

## Step 2 — SSH into IRIS

IRIS is accessed via SSH to the SLURM head node `cepheus-slurm.diamond.ac.uk`. Connections from outside the DLS network require a proxy jump through `ssh.diamond.ac.uk`.

### 2a. Check your group membership

Some FFF functionality requires membership of specific Diamond groups. In a terminal, run:

```bash
groups <yourfedid>
```

Check that the following groups are listed:

| Group | Required for |
|-------|-------------|
| `dls_staff` | Port-forwarding to a Jupyter notebook from outside the DLS network |
| `i04-1_valid_users` | Proxy-jumping and port-forwarding through `ssh.diamond.ac.uk` from outside the DLS firewall (e.g. when not on VPN) |

If either group is missing, contact your FFF-coordinator.

### 2b. Generate SSH keys

SSH key authentication is required to connect to IRIS.

Follow the DLS SSH key generation and configuration guide — available from the FFF coordinator — which covers key creation, copying keys to IRIS, and setting correct file permissions.

In your terminal:

```bash
ssh-keygen -t rsa
# Accept the default location (~/.ssh/id_rsa) and set a passphrase when prompted
ssh-copy-id <yourfedid>@cepheus-slurm.diamond.ac.uk
```

Replace `<yourfedid>` with your own Diamond FedID in all commands below.

### 2c. Connect to IRIS

#### Mac / Linux

1. Set the correct permissions on your key files:

   ```bash
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   ```

2. Connect using a proxy jump through `ssh.diamond.ac.uk`:

   ```bash
   ssh -J <yourfedid>@ssh.diamond.ac.uk <yourfedid>@cepheus-slurm.diamond.ac.uk
   ```

   If you are already inside the DLS network (e.g. via VPN or SSH), you can connect directly:

   ```bash
   ssh <yourfedid>@cepheus-slurm.diamond.ac.uk
   ```

#### Windows — WSL setup

Windows is not natively supported. Windows users must install **Windows Subsystem for Linux (WSL)** to get a full Ubuntu environment with standard shell tools before proceeding.

**Install WSL and Ubuntu:**

1. Open **PowerShell as Administrator** and run:

   ```powershell
   wsl --install
   ```

   This installs WSL 2 with Ubuntu as the default distribution. Restart your machine when prompted.

2. After restarting, Ubuntu will launch automatically to complete first-time setup. Set a Linux username and password when asked.

3. Open **Ubuntu** from the Start menu to get a Linux terminal. All subsequent commands should be run in this terminal.

**Verify the installation:**

```bash
uname -a   # should show a Linux kernel
```

Once WSL is set up, follow the **Mac / Linux** steps above to generate SSH keys and connect to IRIS.

```{note}
If `wsl --install` fails (e.g. on older Windows 10 builds), see the manual install guide at [https://learn.microsoft.com/en-us/windows/wsl/install-manual](https://learn.microsoft.com/en-us/windows/wsl/install-manual).
```

Confirm you can log in and see the IRIS prompt before proceeding.

---

## Step 3 — Prepare your IRIS environment

These steps are performed once on IRIS after your first successful login.

### 3a. Create a working directory

IRIS uses a shared data filesystem. Create a personal working directory named `<INITIAL><LAST_NAME>` (e.g. `jsmith`) and link it to your home:

```bash
mkdir /opt/xchem-fragalysis-2/<WORKDIR>
ln -s /opt/xchem-fragalysis-2/<WORKDIR> $HOME/<WORKDIR>
```

Replace `<WORKDIR>` with your `<INITIAL><LAST_NAME>` throughout.

### 3b. Set up your login profile

The `.bashrc_local` file is sourced automatically at every login. Configure it so your environment is ready without manual steps each session.

```{important}
This edit must be done on a **Diamond machine** (e.g. a DLS Linux desktop or login node), not on IRIS. `nano` is not installed on IRIS. Because your home directory is shared across Diamond systems, the change will take effect when you next log in to IRIS.
```

On a Diamond machine, open the file:

```bash
nano ~/.bashrc_local
```

Add the following block, replacing `<WORKDIR>` with your own directory name:

```bash
if [ $(hostname) == 'cs05r-sc-cloud-30.diamond.ac.uk' ] ; then
    export DATA=/opt/xchem-fragalysis-2
    export HOME2=$DATA/<WORKDIR>
    export XCHEM_FFF=$DATA/XChem-FFF
    export LOGS=$HOME2/logs
fi
```

Load the changes in your current session:

```bash
source ~/.bashrc_local
```

---

## Step 4 — Getting access to Squonk

Placeholder for Squonk onboarding

---

## Next Steps

You are now ready to install the FFF pipeline tools. Continue to the [Setup](setup.md) page.
