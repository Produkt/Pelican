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
  s.source           = { :git => 'https://github.com/Produkt/Pelican.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.libraries = 'z'

  s.source_files = 'src/*.{swift,h}',
                    'src/ZIP/*.{swift}',
                    'src/Helpers/*.{swift}',
                    'src/vendors/minizip/*.{c,h}',
                    'src/vendors/unrar/*.hpp',
                    'src/vendors/unrar/rar.cpp',
                    'src/vendors/unrar/strlist.cpp',
                    'src/vendors/unrar/strfn.cpp',
                    'src/vendors/unrar/pathfn.cpp',
                    'src/vendors/unrar/smallfn.cpp',
                    'src/vendors/unrar/global.cpp',
                    'src/vendors/unrar/file.cpp',
                    'src/vendors/unrar/filefn.cpp',
                    'src/vendors/unrar/filcreat.cpp',
                    'src/vendors/unrar/archive.cpp',
                    'src/vendors/unrar/arcread.cpp',
                    'src/vendors/unrar/unicode.cpp',
                    'src/vendors/unrar/system.cpp',
                    'src/vendors/unrar/isnt.cpp',
                    'src/vendors/unrar/crypt.cpp',
                    'src/vendors/unrar/crc.cpp',
                    'src/vendors/unrar/rawread.cpp',
                    'src/vendors/unrar/encname.cpp',
                    'src/vendors/unrar/resource.cpp',
                    'src/vendors/unrar/match.cpp',
                    'src/vendors/unrar/timefn.cpp',
                    'src/vendors/unrar/rdwrfn.cpp',
                    'src/vendors/unrar/consio.cpp',
                    'src/vendors/unrar/options.cpp',
                    'src/vendors/unrar/errhnd.cpp',
                    'src/vendors/unrar/rarvm.cpp',
                    'src/vendors/unrar/secpassword.cpp',
                    'src/vendors/unrar/rijndael.cpp',
                    'src/vendors/unrar/getbits.cpp',
                    'src/vendors/unrar/sha1.cpp',
                    'src/vendors/unrar/sha256.cpp',
                    'src/vendors/unrar/blake2s.cpp',
                    'src/vendors/unrar/hash.cpp',
                    'src/vendors/unrar/extinfo.cpp',
                    'src/vendors/unrar/extract.cpp',
                    'src/vendors/unrar/volume.cpp',
                    'src/vendors/unrar/list.cpp',
                    'src/vendors/unrar/find.cpp',
                    'src/vendors/unrar/unpack.cpp',
                    'src/vendors/unrar/headers.cpp',
                    'src/vendors/unrar/threadpool.cpp',
                    'src/vendors/unrar/rs16.cpp',
                    'src/vendors/unrar/cmddata.cpp',
                    'src/vendors/unrar/ui.cpp',
                    'src/vendors/unrar/filestr.cpp',
                    'src/vendors/unrar/recvol.cpp',
                    'src/vendors/unrar/rs.cpp',
                    'src/vendors/unrar/scantree.cpp',
                    'src/vendors/unrar/qopen.cpp',
                    'src/vendors/unrar/dll.cpp'
  s.public_header_files = 'src/*.h', 'src/vendors/unrar/raros.hpp', 'src/vendors/unrar/dll.hpp'
  s.preserve_paths  = 'src/vendors/minizip/module.modulemap',
                    'src/vendors/unrar/arccmt.cpp',
                    'src/vendors/unrar/blake2sp.cpp',
                    'src/vendors/unrar/coder.cpp',
                    'src/vendors/unrar/crypt1.cpp',
                    'src/vendors/unrar/crypt2.cpp',
                    'src/vendors/unrar/crypt3.cpp',
                    'src/vendors/unrar/crypt5.cpp',
                    'src/vendors/unrar/hardlinks.cpp',
                    'src/vendors/unrar/log.cpp',
                    'src/vendors/unrar/model.cpp',
                    'src/vendors/unrar/rarvmtbl.cpp',
                    'src/vendors/unrar/recvol3.cpp',
                    'src/vendors/unrar/recvol5.cpp',
                    'src/vendors/unrar/suballoc.cpp',
                    'src/vendors/unrar/uicommon.cpp',
                    'src/vendors/unrar/uisilent.cpp',
                    'src/vendors/unrar/ulinks.cpp',
                    'src/vendors/unrar/unpack15.cpp',
                    'src/vendors/unrar/unpack20.cpp',
                    'src/vendors/unrar/unpack30.cpp',
                    'src/vendors/unrar/unpack50.cpp',
                    'src/vendors/unrar/unpack50frag.cpp',
                    'src/vendors/unrar/unpackinline.cpp',
                    'src/vendors/unrar/uowners.cpp',
                    'src/vendors/unrar/win32stm.cpp'
  s.pod_target_xcconfig = {
                'SWIFT_INCLUDE_PATHS' => "#{File.dirname(__FILE__)}/src/vendors/minizip/** $(SRCROOT)/Pelican/src/vendors/minizip/**",
                'LIBRARY_SEARCH_PATHS' => "#{File.dirname(__FILE__)}/src/ $(SRCROOT)/Pelican/src/",
                'OTHER_LDFLAGS' => "$(inherited) -lc++",
                'OTHER_CFLAGS' => "$(inherited) -Wno-return-type -Wno-logical-op-parentheses -Wno-conversion -Wno-parentheses -Wno-unused-function -Wno-unused-variable -Wno-switch -Wno-unused-command-line-argument",
                'OTHER_CPLUSPLUSFLAGS' => "$(inherited) -DSILENT -DRARDLL $(OTHER_CFLAGS)"
  }
  s.compiler_flags = "-Xanalyzer -analyzer-disable-all-checks"
  s.dependency 'Result', '~> 3.1.0'
end
