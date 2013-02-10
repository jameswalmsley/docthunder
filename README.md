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

Compile the gem:

    $ cd docthunder
    $ gem build docthunder.gemspec

Install docthunder:

    $ sudo gem install DocThunder-0.0.1.gem

## Usage

Currently DocThunder is similar to docurium.

    $ docthunder gen test    # Generate a config file called test
    $ docthunder doc test    # Generate documentation for project configured in test.


## Future Project Type Support

We are aiming to support the following other project types and languages:
   
   * C++
   * VHDL - Describe register layouts, and produce headers files.

