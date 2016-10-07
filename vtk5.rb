# Copyright 2009-2016 Homebrew contributors.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Vtk5 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization."
  homepage "http://www.vtk.org"
  head "http://vtk.org/VTK.git", :branch => "release-5.10"

  bottle do
    root_url "https://s3.amazonaws.com/drake-provisioning/vtk5"
    sha256 "ec8292979ab4fc87917786bfc4b475ece338c25bb6cec1c71027d9a6a136e2d3" => :el_capitan
    sha256 "0b114d5ef4e2ff9d5bb741d5e002711bede94088a881f48b175dc03d3bb3d8f8" => :yosemite
    sha256 "ef4c659ca350f986325fb7138ff91af666033510d2a9a956c1cdc9c2e35a9403" => :mavericks
  end

  stable do
    url "http://www.vtk.org/files/release/5.10/vtk-5.10.1.tar.gz"
    sha256 "f1a240c1f5f0d84e27b57e962f8e4a78b166b25bf4003ae16def9874947ebdbb"

    patch do
      # apply upstream patches for C++11 mode
      url "https://gist.github.com/sxprophet/7463815/raw/165337ae10d5665bc18f0bad645eff098f939893/vtk5-cxx11-patch.diff"
      sha256 "b5946abb41c3d6ede33df636fa1621bbb86c4092cdae7032e3fdc63a5478f03d"
    end
  end

  keg_only "Conflicts with vtk in homebrew/science."

  option :cxx11
  option "with-examples", "Compile and install various examples"
  option "with-qt-extern", "Enable Qt4 extension via non-Homebrew external Qt4"
  option "with-tcl", "Enable Tcl wrapping of VTK classes"
  option "without-legacy", "Disable legacy APIs"

  depends_on "cmake" => :build
  depends_on "qt" => :recommended
  depends_on :python => :recommended
  depends_on "hdf5" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "boost" => :optional
  depends_on :x11 => :optional
  depends_on "pyqt" => :optional

  # If --with-pyqt, then we depend on sip, too.
  if build.with?("pyqt")
    depends_on "sip"
  end


  # Fix bug in Wrapping/Python/setup_install_paths.py: http://vtk.org/Bug/view.php?id=13699
  # and compilation on mavericks backported from head.
  patch :DATA

  def install
    libdir = build.head? ? lib : "#{lib}/vtk-5.10"

    args = std_cmake_args + %W[
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DVTK_USE_CARBON=OFF
      -DVTK_USE_TK=OFF
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DIOKit:FILEPATH=#{MacOS.sdk_path}/System/Library/Frameworks/IOKit.framework
      -DCMAKE_INSTALL_RPATH:STRING=#{libdir}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{libdir}
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
    ]

    args << "-DBUILD_EXAMPLES=" + ((build.with? "examples") ? "ON" : "OFF")

    if build.with?("qt") || build.with?("qt-extern")
      args << "-DVTK_USE_GUISUPPORT=ON"
      args << "-DVTK_USE_QT=ON"
      args << "-DVTK_USE_QVTK=ON"
    end

    args << "-DVTK_WRAP_TCL=ON" if build.with? "tcl"

    # Cocoa for everything except x11
    if build.with? "x11"
      args << "-DVTK_USE_COCOA=OFF"
      args << "-DVTK_USE_X=ON"
    else
      args << "-DVTK_USE_COCOA=ON"
    end

    unless MacOS::CLT.installed?
      # We are facing an Xcode-only installation, and we have to keep
      # vtk from using its internal Tk headers (that differ from OSX's).
      args << "-DTK_INCLUDE_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers"
      args << "-DTK_INTERNAL_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers/tk-private"
    end

    args << "-DVTK_USE_BOOST=ON" if build.with? "boost"
    args << "-DVTK_USE_SYSTEM_HDF5=ON" if build.with? "hdf5"
    args << "-DVTK_USE_SYSTEM_JPEG=ON" if build.with? "jpeg"
    args << "-DVTK_USE_SYSTEM_PNG=ON" if build.with? "libpng"
    args << "-DVTK_USE_SYSTEM_TIFF=ON" if build.with? "libtiff"
    args << "-DVTK_LEGACY_REMOVE=ON" if build.without? "legacy"

    ENV.cxx11 if build.cxx11?

    mkdir "build" do
      if build.with? "python"
        args << "-DVTK_WRAP_PYTHON=ON"
        # CMake picks up the system's python dylib, even if we have a brewed one.
        args << "-DPYTHON_LIBRARY='#{`python-config --prefix`.chomp}/lib/libpython2.7.dylib'"
        # Set the prefix for the python bindings to the Cellar
        args << "-DVTK_PYTHON_SETUP_ARGS:STRING='--prefix=#{prefix} --single-version-externally-managed --record=installed.txt'"

        if build.with? "pyqt"
          args << "-DVTK_WRAP_PYTHON_SIP=ON"
          args << "-DSIP_PYQT_DIR=" # {HOMEBREW_PREFIX}/share/sip""
        end
      end

      args << ".."
      system "cmake", *args
      system "make"
      system "make", "install"
    end

    (share+"vtk").install "Examples" if build.with? "examples"
  end

  def caveats
    s = ""
    s += <<-EOS.undent
        VTK 5 is keg only in favor of VTK 7. Add
            #{opt_prefix}/lib/python2.7/site-packages
        to your PYTHONPATH before using the python bindings.
    EOS

    if build.with? "examples"
      s += <<-EOS.undent

        The scripting examples are stored in #{HOMEBREW_PREFIX}/share/vtk

      EOS
    end
    s.empty? ? nil : s
  end

  test do
    (testpath/"Version.cxx").write <<-EOS
        #include <vtkVersion.h>
        #include <assert.h>
        int main()
        {
          assert(vtkVersion::GetVTKMajorVersion()==5);
          assert(vtkVersion::GetVTKMinorVersion()==10);
          return EXIT_SUCCESS;
        }
      EOS

    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8)
      project(Version)
      find_package(VTK REQUIRED PATHS #{opt_prefix})
      include(${VTK_USE_FILE})
      add_executable(Version Version.cxx)
      target_link_libraries(Version ${VTK_LIBRARIES})
      EOS
    system "cmake", "."
    system "make && ./Version"
  end
end

__END__
diff --git a/Wrapping/Python/setup_install_paths.py b/Wrapping/Python/setup_install_paths.py
index 00f48c8..014b906 100755
--- a/Wrapping/Python/setup_install_paths.py
+++ b/Wrapping/Python/setup_install_paths.py
@@ -35,7 +35,7 @@ def get_install_path(command, *args):
                 option, value = string.split(arg,"=")
                 options[option] = value
             except ValueError:
-                options[option] = 1
+                options[arg] = 1

     # check for the prefix and exec_prefix
     try:


