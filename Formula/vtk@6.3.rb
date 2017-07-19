# Copyright 2012-2017 Robot Locomotion Group @ CSAIL. All rights reserved.
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
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Copyright 2009-2017 Homebrew contributors.
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
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class VtkAT63 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization."
  homepage "http://www.vtk.org/"
  head "https://gitlab.kitware.com/vtk/vtk.git", :branch => "release-6.3"

  stable do
    url "https://donn8mmazi9jw.cloudfront.net/mirror/vtk-6.3.0.tar.gz"
    sha256 "92a493354c5fa66bea73b5fc014154af5d9f3f6cee8d20a826f4cd5d4b0e8a5e"

    patch do
      # Do not require Qt WebKit.
      url "https://donn8mmazi9jw.cloudfront.net/patches/vtk-6.3.0-optional-qt-webkit.patch"
      sha256 "2e0563e178c0a57cc845cf8c20de8fffb27e09c09055be0cb2eb03223ebe5a6c"
    end

    patch do
      # Do not link against libpython when possible.
      url "https://donn8mmazi9jw.cloudfront.net/patches/vtk-6.3.0-optional-python-link.patch"
      sha256 "08389ed44c19416c0780d4a898afb0d96c8b38b1089661b5bcef1146ffafa0d3"
    end
  end

  bottle do
    root_url "https://donn8mmazi9jw.cloudfront.net/bottles"
    sha256 "149548918f910370318acbd4d69b83566e51ed0a848dc70bdddf66fe63e540a2" => :sierra
    sha256 "014dd129dbbc636d10856ddf5d5a99477539dcb44c6c8557647c527c239da862" => :el_capitan
    sha256 "397f7f5852f74e769f1c6c3a0949b2a5bb826f3b96001489cb81524f94387dfb" => :yosemite
  end

  keg_only :versioned_formula

  option :cxx11
  option "with-examples", "Compile and install various examples"
  option "with-tcl", "Enable Tcl wrapping of VTK classes"
  option "with-matplotlib", "Enable matplotlib support"
  option "without-legacy", "Disable legacy APIs"
  option "without-python", "Build without python support"

  depends_on "cmake" => :build

  unless OS.mac?
    depends_on "libxml2"
    depends_on "linuxbrew/xorg/mesa"
  end

  depends_on :python => :recommended
  depends_on "matplotlib" => :python if build.with?("matplotlib") && build.with?("python") # homebrew/science

  depends_on "freetype" => :recommended
  depends_on "glew" => :recommended
  depends_on "hdf5" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "jsoncpp" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "netcdf" => :recommended # homebrew/science
  depends_on "qt" => :recommended
  depends_on "zlib" => :recommended

  depends_on "boost" => :optional
  depends_on "fontconfig" => :optional
  depends_on :x11 => :optional

  # If --with-qt and --with-python, then we automatically use PyQt, too!
  if build.with?("qt") && build.with?("python")
    depends_on "pyqt"
    depends_on "sip"
  end

  def install
    dylib = OS.mac? ? "dylib" : "so"

    args = std_cmake_args + %W[
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
    ]

    args << "-DBUILD_EXAMPLES=" + ((build.with? "examples") ? "ON" : "OFF")

    if build.with? "examples"
      args << "-DBUILD_TESTING=ON"
    else
      args << "-DBUILD_TESTING=OFF"
    end

    if build.with? "qt"
      args << "-DVTK_QT_VERSION:STRING=5"
      args << "-DVTK_Group_Qt=ON"
    end

    args << "-DVTK_WRAP_TCL=ON" if build.with? "tcl"

    # Cocoa for everything except x11
    if build.with? "x11"
      args << "-DVTK_USE_COCOA=OFF"
      args << "-DVTK_USE_X=ON"
      args << "-DOPENGL_INCLUDE_DIR:PATH=/usr/X11R6/include"
      args << "-DOPENGL_gl_LIBRARY:STRING=/usr/X11R6/lib/libGL.dylib"
      args << "-DOPENGL_glu_LIBRARY:STRING=/usr/X11R6/lib/libGLU.dylib"
    else
      args << "-DVTK_USE_COCOA=ON"
    end

    unless MacOS::CLT.installed?
      # We are facing an Xcode-only installation, and we have to keep
      # vtk from using its internal Tk headers (that differ from OSX's).
      args << "-DTK_INCLUDE_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers"
      args << "-DTK_INTERNAL_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers/tk-private"
    end

    args << "-DModule_vtkInfovisBoost=ON" << "-DModule_vtkInfovisBoostGraphAlgorithms=ON" if build.with? "boost"
    args << "-DModule_vtkRenderingFreeTypeFontConfig=ON" if build.with? "fontconfig"
    args << "-DVTK_USE_SYSTEM_FREETYPE=ON" if build.with? "freetype"
    args << "-DVTK_USE_SYSTEM_GLEW=ON" if build.with? "glew"
    args << "-DVTK_USE_SYSTEM_HDF5=ON" if build.with? "hdf5"
    args << "-DVTK_USE_SYSTEM_JPEG=ON" if build.with? "jpeg"
    args << "-DVTK_USE_SYSTEM_JSONCPP=ON" if build.with? "jsoncpp"
    args << "-DVTK_USE_SYSTEM_NETCDF=ON" if build.with? "netcdf"
    args << "-DVTK_USE_SYSTEM_PNG=ON" if build.with? "libpng"
    args << "-DVTK_USE_SYSTEM_TIFF=ON" if build.with? "libtiff"
    args << "-DModule_vtkRenderingMatplotlib=ON" if build.with?("matplotlib") && build.with?("python")
    args << "-DVTK_LEGACY_REMOVE=ON" if build.without? "legacy"

    ENV.cxx11 if build.cxx11?

    mkdir "build" do
      if build.with? "python"
        python_executable = `which python2`.strip

        python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp
        python_include = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
        python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
        py_site_packages = "#{lib}/#{python_version}/site-packages"

        args << "-DVTK_WRAP_PYTHON=ON"
        args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
        args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
        # CMake picks up the system's python dylib, even if we have a brewed one.
        if File.exist? "#{python_prefix}/Python"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.a'"
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.#{dylib}"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.#{dylib}'"
        elsif File.exist? "#{python_prefix}/lib/x86_64-linux-gnu/lib#{python_version}.so"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/x86_64-linux-gnu/lib#{python_version}.so'"
        else
          odie "No libpythonX.Y.{#{dylib}|a} file found!"
        end
        # Set the prefix for the python bindings to the Cellar
        args << "-DVTK_INSTALL_PYTHON_MODULE_DIR='#{py_site_packages}/'"

        if build.with? "qt"
          args << "-DVTK_WRAP_PYTHON_SIP=ON"
          args << "-DSIP_PYQT_DIR='#{Formula["pyqt"].opt_share}/sip'"
        end
      end

      args << ".."
      system "cmake", *args
      system "make"
      system "make", "install"

      if build.with? "hdf5"
        inreplace "#{lib}/cmake/vtk-6.3/Modules/vtkhdf5.cmake", "#{HOMEBREW_CELLAR}/hdf5/#{Formula["hdf5"].installed_version}/include", "#{Formula["hdf5"].opt_include}"
      end
      if build.with? "python"
        inreplace "#{lib}/cmake/vtk-6.3/Modules/vtkPython.cmake", "#{HOMEBREW_CELLAR}/python/#{Formula["python"].installed_version}/Frameworks", "#{Formula["python"].opt_prefix}/Frameworks"
      end
      inreplace "#{lib}/cmake/vtk-6.3/VTKConfig.cmake", prefix, opt_prefix
      inreplace "#{lib}/cmake/vtk-6.3/VTKTargets-release.cmake", lib, opt_lib
    end

    pkgshare.install "Examples" if build.with? "examples"
  end

  test do
    (testpath/"Version.cpp").write <<-EOS
        #include <vtkVersion.h>
        #include <assert.h>
        int main() {
          assert(vtkVersion::GetVTKMajorVersion()==6);
          assert(vtkVersion::GetVTKMinorVersion()==3);
          return 0;
        }
      EOS

    system ENV.cxx, "Version.cpp", "-I#{opt_include}/vtk-6.3"
    system "./a.out"
    system "#{bin}/vtkpython", "-c", "exit()"
  end
end
