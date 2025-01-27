# Fork Info

Forked from the fork [DGGua/xilinx-tools-docker the origin](https://github.com/DGGua/xilinx-tools-docker) of the repository [esnet/xilinx-tools-docker](https://github.com/esnet/xilinx-tools-docker.git) as part of my search for a good way to use the Xlinix tools on a an Intel Mac. The fork is a work in progress. The docker image takes a long time to build and also consumes aproximatly 2010 Gb. XRDP probably needs some tweaking as well.

Todo:
- Add missing boards to Vivado this is a tweak to the installer config file
- Add Vitus
- Petalinux
- DocNav
- SSH to allow Visual Studio Code to open git repositories in the docker file to work on them. 

In this fork, we changed the setup pipeline:

+ Download the Xilinx Vivado installer from [https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html), Download the SFD file.

+ extract the TAR/GZIP file, copy the folder to the `vivado-installer` directory, change name as `Xilinx_Unified`.

+ run `./vivado-installer/Xilinx_Unified/xsetup -b ConfigGen`, select the product and confirm. The generated config file will be available at `~/.Xilinx/install_config.txt`.

+ copy the generated file to the `vivado-installer`.

+ build the docker 

# Now the Fork Has Verified the Xilinx Vivado Installation v2021.2 v2021.2

# Origin Repository README

# Copyright Notice

ESnet SmartNIC Copyright (c) 2022, The Regents of the University of
California, through Lawrence Berkeley National Laboratory (subject to
receipt of any required approvals from the U.S. Dept. of Energy),
12574861 Canada Inc., Malleable Networks Inc., and Apical Networks, Inc.
All rights reserved.

If you have questions about your rights to use or distribute this software,
please contact Berkeley Lab's Intellectual Property Office at
IPO@lbl.gov.

NOTICE.  This Software was developed under funding from the U.S. Department
of Energy and the U.S. Government consequently retains certain rights.  As
such, the U.S. Government has been granted for itself and others acting on
its behalf a paid-up, nonexclusive, irrevocable, worldwide license in the
Software to reproduce, distribute copies to the public, prepare derivative
works, and perform publicly and display publicly, and to permit others to do so.


# Support

The ESnet SmartNIC platform is made available in the hope that it will
be useful to the networking community. Users should note that it is
made available on an "as-is" basis, and should not expect any
technical support or other assistance with building or using this
software. For more information, please refer to the LICENSE.md file in
each of the source code repositories.

The developers of the ESnet SmartNIC platform can be reached by email
at smartnic@es.net.


Download the Xilinx Vivado Installer
------------------------------------

* Open a web browser to this page: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2023-2.html
* Under the `Vivado ML Edition - 2023.2  Full Product Installation` section
  * Download `AMD Unified Installer for FPGAs & Adaptive SoCs 2023.2 SFD`
  * Save the file as exactly: `FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz`
+* Under the `Vivado ML Edition Update 2 - 2023.2  Product Update` section
+  * Download `AMD Unified Installer for FPGAs & Adaptive SoCs 2023.2.2`
* Move the files into the `vivado-installer` directory in this repo

```
$ tree
.
├── Dockerfile
├── entrypoint.sh
├── LICENSE.md
├── patches
│   └── vivado-2023.2-postinstall.patch
├── README.md
└── vivado-installer
    ├── install_config_vivado.2023.2.txt
    ├── FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz   <--------- put the base installer here
    └── Vivado_Vitis_Update_2023.2.2_0209_0950.tar.gz        <--------- put the update installer here
```

Building the xilinx-tools-docker container
------------------------------------------

```
docker build --pull -t xilinx-tools-docker:v2023.2.2-latest .
docker image ls
```

You should see an image called `xilinx-tools-docker` with tag `v2023.2.2-latest`.
