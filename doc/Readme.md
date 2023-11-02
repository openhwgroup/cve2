# CVE2 Documentation

The documentation of CVE2 is written in reStructuredText and compiled to HTML using Sphinx. For more information, check https://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html.

## Prerequisites

To build the documentation, certain prequisites need to be fulfilled. This section outlines the necessary steps on Linux. Tested on Ubuntu 20.04.

Sphinx is based on Python and requires at least version 3.8. Additionally, `make` is required and can be installed through build-essential.

```bash
sudo apt update
sudo apt install python3
sudo apt install build-essential
```

Please verify your Python version using

```bash
python3 --version
```

The recommended way of installing Sphinx is via `pip` using

```bash
pip install -U sphinx
```

Sphinx requires certain packages to build this documentation. These are summarized in `doc/requirements.txt`. They can automatically be installed using

```bash
cd doc
pip install -r requirements.txt
```

## Building the documentation

To build the documentation, switch to the `doc` folder if not already done. Build is invoked via the `make` command. Typically, an HTML should be build. 

```bash
cd doc
make html
```

Simply type only `make` to view other available targets.
