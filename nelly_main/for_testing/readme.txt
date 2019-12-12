nelly_main MATLAB Python Package

1. Prerequisites for Deployment 

Verify that version 9.10 (R2021a) of the MATLAB Runtime is installed.   
If not, you can run the MATLAB Runtime installer.
To find its location, enter
  
    >>mcrinstaller
      
at the MATLAB prompt.

Alternatively, download and install the Linux version of the MATLAB Runtime for R2021a 
from the following link on the MathWorks website:

    https://www.mathworks.com/products/compiler/mcr/index.html
   
For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
"Distribute Applications" in the MATLAB Compiler SDK documentation  
in the MathWorks Documentation Center.

Verify that a Linux version of Python 2.7, 3.7, and/or 3.8 is installed.

2. Installing the nelly_main Package

A. Change to the directory that contains the file setup.py and the subdirectory 
nelly_main. If you do not have write permissions, copy all its contents to a temporary 
location and change to that directory.

B. Execute the command:

    python setup.py install [options]
    
If you have full administrator privileges, and install to the default location, you do 
not need to specify any options. Otherwise, use --user to install to your home folder, or 
--prefix="installdir" to install to "installdir". In the latter case, add "installdir" to 
the PYTHONPATH environment variable. For details, refer to:

    https://docs.python.org/2/install/index.html

C. Set environment variables as follows:

In the following directions, replace MR/v910 by the directory on the target machine where MATLAB is installed, or MR by the directory where the MATLAB Runtime is installed.

(1) Set the environment variable XAPPLRESDIR to this value:

MR/v910/X11/app-defaults


(2) If the environment variable LD_LIBRARY_PATH is undefined, set it to the following:

MR/v910/runtime/glnxa64:MR/v910/bin/glnxa64:MR/v910/sys/os/glnxa64:MR/v910/sys/opengl/lib/glnxa64

If it is defined, set it to the following:

${LD_LIBRARY_PATH}:MR/v910/runtime/glnxa64:MR/v910/bin/glnxa64:MR/v910/sys/os/glnxa64:MR/v910/sys/opengl/lib/glnxa64

3. Using the nelly_main Package

The nelly_main package is on your Python path. To import it into a Python script or 
session, execute:

    import nelly_main

If a namespace must be specified for the package, modify the import statement accordingly.
