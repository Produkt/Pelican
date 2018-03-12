#
# Be sure to run `pod lib lint Zip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Pelican"
  s.version          = "0.0.1"
  s.summary          = "Utility class for compressing/decompressing files on iOS and Mac."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                      Pelican is a simple utility class for compressing/decompressing files on iOS and Mac.
                     DESC

  s.homepage         = "https://github.com/Produkt/Pelican"
  s.license          = { :type => 'GPL', :file => 'LICENSE' }
  s.author           = { 'Daniel Garcia' => 'fillito@gmail.com' }
  s.source           = { :git => 'https://github.com/Produkt/Pelican.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.libraries = 'z'

  s.source_files = 'src/*.{swift,h}',
                    'src/ZIP/*.{swift}',
                    'src/RAR/*.{swift}',
                    'src/Helpers/*.{swift}',
                    'src/vendors/UnrarKit/*.{h,m,mm}',
                    'src/vendors/UnrarKit/**/*.{h,m,mm}',
                    'src/vendors/minizip/*.{c,h}',
                    'src/vendors/UnrarKit/unrar/*.hpp',
                    'src/vendors/UnrarKit/unrar/rar.cpp',
                    'src/vendors/UnrarKit/unrar/strlist.cpp',
                    'src/vendors/UnrarKit/unrar/strfn.cpp',
                    'src/vendors/UnrarKit/unrar/pathfn.cpp',
                    'src/vendors/UnrarKit/unrar/smallfn.cpp',
                    'src/vendors/UnrarKit/unrar/global.cpp',
                    'src/vendors/UnrarKit/unrar/file.cpp',
                    'src/vendors/UnrarKit/unrar/filefn.cpp',
                    'src/vendors/UnrarKit/unrar/filcreat.cpp',
                    'src/vendors/UnrarKit/unrar/archive.cpp',
                    'src/vendors/UnrarKit/unrar/arcread.cpp',
                    'src/vendors/UnrarKit/unrar/unicode.cpp',
                    'src/vendors/UnrarKit/unrar/system.cpp',
                    'src/vendors/UnrarKit/unrar/isnt.cpp',
                    'src/vendors/UnrarKit/unrar/crypt.cpp',
                    'src/vendors/UnrarKit/unrar/crc.cpp',
                    'src/vendors/UnrarKit/unrar/rawread.cpp',
                    'src/vendors/UnrarKit/unrar/encname.cpp',
                    'src/vendors/UnrarKit/unrar/resource.cpp',
                    'src/vendors/UnrarKit/unrar/match.cpp',
                    'src/vendors/UnrarKit/unrar/timefn.cpp',
                    'src/vendors/UnrarKit/unrar/rdwrfn.cpp',
                    'src/vendors/UnrarKit/unrar/consio.cpp',
                    'src/vendors/UnrarKit/unrar/options.cpp',
                    'src/vendors/UnrarKit/unrar/errhnd.cpp',
                    'src/vendors/UnrarKit/unrar/rarvm.cpp',
                    'src/vendors/UnrarKit/unrar/secpassword.cpp',
                    'src/vendors/UnrarKit/unrar/rijndael.cpp',
                    'src/vendors/UnrarKit/unrar/getbits.cpp',
                    'src/vendors/UnrarKit/unrar/sha1.cpp',
                    'src/vendors/UnrarKit/unrar/sha256.cpp',
                    'src/vendors/UnrarKit/unrar/blake2s.cpp',
                    'src/vendors/UnrarKit/unrar/hash.cpp',
                    'src/vendors/UnrarKit/unrar/extinfo.cpp',
                    'src/vendors/UnrarKit/unrar/extract.cpp',
                    'src/vendors/UnrarKit/unrar/volume.cpp',
                    'src/vendors/UnrarKit/unrar/list.cpp',
                    'src/vendors/UnrarKit/unrar/find.cpp',
                    'src/vendors/UnrarKit/unrar/unpack.cpp',
                    'src/vendors/UnrarKit/unrar/headers.cpp',
                    'src/vendors/UnrarKit/unrar/threadpool.cpp',
                    'src/vendors/UnrarKit/unrar/rs16.cpp',
                    'src/vendors/UnrarKit/unrar/cmddata.cpp',
                    'src/vendors/UnrarKit/unrar/ui.cpp',
                    'src/vendors/UnrarKit/unrar/filestr.cpp',
                    'src/vendors/UnrarKit/unrar/recvol.cpp',
                    'src/vendors/UnrarKit/unrar/rs.cpp',
                    'src/vendors/UnrarKit/unrar/scantree.cpp',
                    'src/vendors/UnrarKit/unrar/qopen.cpp',
                    'src/vendors/UnrarKit/unrar/dll.cpp'
  s.public_header_files = 'src/*.h', 'src/vendors/UnrarKit/unrar/raros.hpp', 'src/vendors/UnrarKit/unrar/dll.hpp'
  s.preserve_paths  = 'src/vendors/minizip/module.modulemap',
                    'src/vendors/UnrarKit/module.modulemap',
                    'src/vendors/UnrarKit/unrar/arccmt.cpp',
                    'src/vendors/UnrarKit/unrar/blake2sp.cpp',
                    'src/vendors/UnrarKit/unrar/coder.cpp',
                    'src/vendors/UnrarKit/unrar/crypt1.cpp',
                    'src/vendors/UnrarKit/unrar/crypt2.cpp',
                    'src/vendors/UnrarKit/unrar/crypt3.cpp',
                    'src/vendors/UnrarKit/unrar/crypt5.cpp',
                    'src/vendors/UnrarKit/unrar/hardlinks.cpp',
                    'src/vendors/UnrarKit/unrar/log.cpp',
                    'src/vendors/UnrarKit/unrar/model.cpp',
                    'src/vendors/UnrarKit/unrar/rarvmtbl.cpp',
                    'src/vendors/UnrarKit/unrar/recvol3.cpp',
                    'src/vendors/UnrarKit/unrar/recvol5.cpp',
                    'src/vendors/UnrarKit/unrar/suballoc.cpp',
                    'src/vendors/UnrarKit/unrar/uicommon.cpp',
                    'src/vendors/UnrarKit/unrar/uisilent.cpp',
                    'src/vendors/UnrarKit/unrar/ulinks.cpp',
                    'src/vendors/UnrarKit/unrar/unpack15.cpp',
                    'src/vendors/UnrarKit/unrar/unpack20.cpp',
                    'src/vendors/UnrarKit/unrar/unpack30.cpp',
                    'src/vendors/UnrarKit/unrar/unpack50.cpp',
                    'src/vendors/UnrarKit/unrar/unpack50frag.cpp',
                    'src/vendors/UnrarKit/unrar/unpackinline.cpp',
                    'src/vendors/UnrarKit/unrar/uowners.cpp',
                    'src/vendors/UnrarKit/unrar/win32stm.cpp'
  s.pod_target_xcconfig = {
                'SWIFT_INCLUDE_PATHS' => "#{File.dirname(__FILE__)}/src/vendors/minizip/** $(SRCROOT)/Pelican/src/vendors/minizip/** #{File.dirname(__FILE__)}/src/vendors/UnrarKit/** $(SRCROOT)/Pelican/src/vendors/UnrarKit/**",
                'LIBRARY_SEARCH_PATHS' => "#{File.dirname(__FILE__)}/src/ $(SRCROOT)/Pelican/src/",
                'OTHER_LDFLAGS' => "$(inherited) -lc++",
                'OTHER_CFLAGS' => "$(inherited) -Wno-return-type -Wno-logical-op-parentheses -Wno-conversion -Wno-parentheses -Wno-unused-function -Wno-unused-variable -Wno-switch -Wno-unused-command-line-argument",
                'OTHER_CPLUSPLUSFLAGS' => "$(inherited) -DSILENT -DRARDLL $(OTHER_CFLAGS)"
  }
  s.compiler_flags = "-Xanalyzer -analyzer-disable-all-checks"
end
