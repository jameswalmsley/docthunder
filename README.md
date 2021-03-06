# DocThunder

DocThunder is a doxygen replacement for C code projects.
DocThunder is based heavily on docurium from github, but attempts to separate
the parsing and output stages completely.

This allows DocThunder to easily target multiple output formats using a simple
template system.

Of course we shall be providing the original docurium like template!

## Install

Clone the source with git:

    $ git clone git://github.com/jameswalmsley/docthunder.git

Install pre-requisited:

    $ sudo gem install colored rocco version_sorter
    $ sudo pip install pygments

Compile the gem:

    $ cd docthunder
    $ gem build docthunder.gemspec

Install docthunder:

    $ sudo gem install DocThunder-0.0.1.gem

This will install all ruby based dependencies automatically.
DocThunder can also generate literate programming documentation, using Rocco.
Rocco has a python dependency for a library called pygments.

If this is not available, then a web-service will be used instead.

Install Pygments:

    $ sudo apt-get install python-pygments
	
Or

    $ sudo pip install pygments

## Usage

Currently DocThunder is similar to docurium.

    $ docthunder gen test    # Generate a config file called test
    $ docthunder doc test    # Generate documentation for project configured in test.


## Future Project Type Support

We are aiming to support the following other project types and languages:
   
   * C++
   * VHDL - Describe register layouts, and produce headers files.

