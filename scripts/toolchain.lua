--
-- Copyright 2010-2015 Branimir Karadzic. All rights reserved.
-- License: https://github.com/bkaradzic/bx#license-bsd-2-clause
--

local naclToolchain = ""
local toolchainPrefix = ""

if _OPTIONS['TOOLCHAIN'] then
	toolchainPrefix = _OPTIONS["TOOLCHAIN"]
end

newoption {
	trigger = "gcc",
	value = "GCC",
	description = "Choose GCC flavor",
	allowed = {
		{ "android-arm",   "Android - ARM"          },
		{ "android-mips",  "Android - MIPS"         },
		{ "android-x86",   "Android - x86"          },
		{ "asmjs",         "Emscripten/asm.js"      },
		{ "freebsd",       "FreeBSD"                },
		{ "linux-gcc",     "Linux (GCC compiler)"   },
		{ "linux-clang",   "Linux (Clang compiler)" },
		{ "ios-arm",       "iOS - ARM"              },
		{ "ios-simulator", "iOS - Simulator"        },
		{ "mingw32-gcc",   "MinGW32"                },
		{ "mingw64-gcc",   "MinGW64"                },
		{ "mingw-clang",   "MinGW (clang compiler)" },
		{ "netbsd",        "NetBSD"                },
		{ "os2",           "OS/2"                   },
		{ "osx",           "OSX (GCC compiler)"     },
		{ "osx-clang",     "OSX (Clang compiler)"   },
		{ "pnacl",         "Native Client - PNaCl"  },
		{ "qnx-arm",       "QNX/Blackberry - ARM"   },
		{ "rpi",           "RaspberryPi"            },
		{ "solaris", 	   "Solaris"                },
		{ "steamlink", 	   "Steam Link"             },
	},
}

newoption {
	trigger = "vs",
	value = "toolset",
	description = "Choose VS toolset",
	allowed = {
		{ "intel-14",	   "Intel C++ Compiler XE 14.0" },
		{ "intel-15",	   "Intel C++ Compiler XE 15.0" },
		{ "vs2013-clang",  "Clang 3.6"         },
		{ "vs2015-clang",  "Clang 3.6"         },
		{ "vs2013-xp", 	   "Visual Studio 2013 targeting XP" },
		{ "vs2015-xp", 	   "Visual Studio 2015 targeting XP" },
		{ "winphone8",     "Windows Phone 8.0" },
		{ "winphone81",    "Windows Phone 8.1" },
		{ "winstore81",    "Windows Store 8.1" },
		{ "winstore82",    "Universal Windows App" }
	},
}

newoption {
	trigger = "xcode",
	value = "xcode_target",
	description = "Choose XCode target",
	allowed = {
		{ "osx", "OSX" },
		{ "ios", "iOS" },
	}
}

newoption {
	trigger = "with-android",
	value   = "#",
	description = "Set Android platform version (default: android-14).",
}

newoption {
	trigger = "with-ios",
	value   = "#",
	description = "Set iOS target version (default: 8.0).",
}

function toolchain(_buildDir, _subDir)

	location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION)

	local androidPlatform = "android-14"
	if _OPTIONS["with-android"] then
		androidPlatform = "android-" .. _OPTIONS["with-android"]
	end

	local iosPlatform = ""
	if _OPTIONS["with-ios"] then
		iosPlatform = _OPTIONS["with-ios"]
	end

	if _ACTION == "gmake" then

		if nil == _OPTIONS["gcc"] or nil == _OPTIONS["gcc_version"] then
			print("GCC flavor and version must be specified!")
			os.exit(1)
		end

		if "android-arm" == _OPTIONS["gcc"] then

			if not os.getenv("ANDROID_NDK_ARM") or not os.getenv("ANDROID_NDK_ROOT") then
				print("Set ANDROID_NDK_ARM and ANDROID_NDK_ROOT envrionment variables.")
			end

			premake.gcc.cc  = "$(ANDROID_NDK_ROOT)/toolchains/llvm-3.6/prebuilt/windows-x86_64/bin/clang.exe"			
			premake.gcc.cxx = "$(ANDROID_NDK_ROOT)/toolchains/llvm-3.6/prebuilt/windows-x86_64/bin/clang++.exe"
			premake.gcc.ar  = "$(ANDROID_NDK_ARM)/bin/arm-linux-androideabi-ar"
			premake.gcc.llvm = true
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-android-arm")
		end

		if "android-mips" == _OPTIONS["gcc"] then

			if not os.getenv("ANDROID_NDK_MIPS") or not os.getenv("ANDROID_NDK_ROOT") then
				print("Set ANDROID_NDK_MIPS and ANDROID_NDK_ROOT envrionment variables.")
			end

			premake.gcc.cc  = "$(ANDROID_NDK_ROOT)/toolchains/llvm-3.6/prebuilt/windows-x86_64/bin/clang.exe"			
			premake.gcc.cxx = "$(ANDROID_NDK_ROOT)/toolchains/llvm-3.6/prebuilt/windows-x86_64/bin/clang++.exe"
			premake.gcc.ar  = "$(ANDROID_NDK_MIPS)/bin/mipsel-linux-android-ar"
			premake.gcc.llvm = true
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-android-mips")
		end

		if "android-x86" == _OPTIONS["gcc"] then

			if not os.getenv("ANDROID_NDK_X86") or not os.getenv("ANDROID_NDK_ROOT") then
				print("Set ANDROID_NDK_X86 and ANDROID_NDK_ROOT envrionment variables.")
			end

			premake.gcc.cc  = "$(ANDROID_NDK_ROOT)/toolchains/llvm-3.6/prebuilt/windows-x86_64/bin/clang.exe"			
			premake.gcc.cxx = "$(ANDROID_NDK_ROOT)/toolchains/llvm-3.6/prebuilt/windows-x86_64/bin/clang++.exe"
			premake.gcc.ar  = "$(ANDROID_NDK_X86)/bin/i686-linux-android-ar"
			premake.gcc.llvm = true
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-android-x86")
		end

		if "asmjs" == _OPTIONS["gcc"] then

			if not os.getenv("EMSCRIPTEN") then
				print("Set EMSCRIPTEN enviroment variables.")
			end

			premake.gcc.cc   = "$(EMSCRIPTEN)/emcc"
			premake.gcc.cxx  = "$(EMSCRIPTEN)/em++"
			premake.gcc.ar   = "$(EMSCRIPTEN)/emar"
			premake.gcc.llvm = true
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-asmjs")
		end

		if "freebsd" == _OPTIONS["gcc"] then
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-freebsd")
		end

		if "netbsd" == _OPTIONS["gcc"] then
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-netbsd")
		end

		if "ios-arm" == _OPTIONS["gcc"] then
			premake.gcc.cc  = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
			premake.gcc.cxx = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
			premake.gcc.ar  = "ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-ios-arm")
		end

		if "ios-simulator" == _OPTIONS["gcc"] then
			premake.gcc.cc  = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
			premake.gcc.cxx = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
			premake.gcc.ar  = "ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-ios-simulator")
		end

		if "linux-gcc" == _OPTIONS["gcc"] then
			-- Force gcc-4.2 on ubuntu-intrepid
			if _OPTIONS["distro"]=="ubuntu-intrepid" then
				premake.gcc.cc   = "@gcc -V 4.2"
				premake.gcc.cxx  = "@g++-4.2"
			end
			premake.gcc.ar  = "ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-linux")
		end

		if "solaris" == _OPTIONS["gcc"] then
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-solaris")
		end


		if "linux-clang" == _OPTIONS["gcc"] then
			premake.gcc.cc  = "clang"
			premake.gcc.cxx = "clang++"
			premake.gcc.ar  = "ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-linux-clang")
		end

		if "steamlink" == _OPTIONS["gcc"] then
			if not os.getenv("MARVELL_SDK_PATH") then
				print("Set MARVELL_SDK_PATH envrionment variable.")
			end
			premake.gcc.cc  = "$(MARVELL_SDK_PATH)/toolchain/bin/armv7a-cros-linux-gnueabi-gcc"
			premake.gcc.cxx = "$(MARVELL_SDK_PATH)/toolchain/bin/armv7a-cros-linux-gnueabi-g++"
			premake.gcc.ar  = "$(MARVELL_SDK_PATH)/toolchain/bin/armv7a-cros-linux-gnueabi-ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-steamlink")
		end

		if "mingw32-gcc" == _OPTIONS["gcc"] then
			if not os.getenv("MINGW32") then
				print("Set MINGW32 envrionment variable.")
			end
			if not toolchainPrefix then
				toolchainPrefix = "$(MINGW32)/bin/i686-w64-mingw32-"
			end
			premake.gcc.cc  = toolchainPrefix .. "gcc"
			premake.gcc.cxx = toolchainPrefix .. "g++"
-- work around GCC 4.9.2 not having proper linker for LTO=1 usage
			local version_4_ar = str_to_version(_OPTIONS["gcc_version"])
			if (version_4_ar < 50000) then
				premake.gcc.ar  = toolchainPrefix .. "ar"
			end
			if (version_4_ar >= 50000) then
				premake.gcc.ar  = toolchainPrefix .. "gcc-ar"
			end
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-mingw32-gcc")
		end

		if "mingw64-gcc" == _OPTIONS["gcc"] then
			if not os.getenv("MINGW64") then
				print("Set MINGW64 envrionment variable.")
			end
			if not toolchainPrefix then
				toolchainPrefix = "$(MINGW64)/bin/x86_64-w64-mingw32-"
			end
			premake.gcc.cc  = toolchainPrefix .. "gcc"
			premake.gcc.cxx = toolchainPrefix .. "g++"
-- work around GCC 4.9.2 not having proper linker for LTO=1 usage
			local version_4_ar = str_to_version(_OPTIONS["gcc_version"])
			if (version_4_ar < 50000) then
				premake.gcc.ar  = toolchainPrefix .. "ar"
			end
			if (version_4_ar >= 50000) then
				premake.gcc.ar  = toolchainPrefix .. "gcc-ar"
			end
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-mingw64-gcc")
		end

		if "mingw-clang" == _OPTIONS["gcc"] then
			premake.gcc.cc   = "clang"
			premake.gcc.cxx  = "clang++"
			premake.gcc.ar   = "llvm-ar"
			premake.gcc.llvm = true
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-mingw-clang")
		end

		if "osx" == _OPTIONS["gcc"] then
			if os.is("linux") then
				premake.gcc.cc  = toolchainPrefix .. "clang"
				premake.gcc.cxx = toolchainPrefix .. "clang++"
				premake.gcc.ar  = toolchainPrefix .. "ar"
			end
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-osx")
		end

		if "osx-clang" == _OPTIONS["gcc"] then
			premake.gcc.cc  = toolchainPrefix .. "clang"
			premake.gcc.cxx = toolchainPrefix .. "clang++"
			premake.gcc.ar  = toolchainPrefix .. "ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-osx-clang")
		end

		if "pnacl" == _OPTIONS["gcc"] then

			if not os.getenv("NACL_SDK_ROOT") then
				print("Set NACL_SDK_ROOT enviroment variables.")
			end

			naclToolchain = "$(NACL_SDK_ROOT)/toolchain/win_pnacl/bin/pnacl-"
			if os.is("macosx") then
				naclToolchain = "$(NACL_SDK_ROOT)/toolchain/mac_pnacl/bin/pnacl-"
			elseif os.is("linux") then
				naclToolchain = "$(NACL_SDK_ROOT)/toolchain/linux_pnacl/bin/pnacl-"
			end

			premake.gcc.cc  = naclToolchain .. "clang"
			premake.gcc.cxx = naclToolchain .. "clang++"
			premake.gcc.ar  = naclToolchain .. "ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-pnacl")
		end

		if "qnx-arm" == _OPTIONS["gcc"] then

			if not os.getenv("QNX_HOST") then
				print("Set QNX_HOST enviroment variables.")
			end

			premake.gcc.cc  = "$(QNX_HOST)/usr/bin/arm-unknown-nto-qnx8.0.0eabi-gcc"
			premake.gcc.cxx = "$(QNX_HOST)/usr/bin/arm-unknown-nto-qnx8.0.0eabi-g++"
			premake.gcc.ar  = "$(QNX_HOST)/usr/bin/arm-unknown-nto-qnx8.0.0eabi-ar"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-qnx-arm")
		end

		if "rpi" == _OPTIONS["gcc"] then
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-rpi")
		end

		if "os2" == _OPTIONS["gcc"] then
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-os2")
		end
	elseif _ACTION == "vs2013" or _ACTION == "vs2015" then

		if (_ACTION .. "-clang") == _OPTIONS["vs"] then
			premake.vstudio.toolset = ("LLVM-" .. _ACTION)
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-clang")
		end

		if "winphone8" == _OPTIONS["vs"] then
			premake.vstudio.toolset = "v110_wp80"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-winphone8")
		end

		if "winphone81" == _OPTIONS["vs"] then
			premake.vstudio.toolset = "v120_wp81"
			platforms { "ARM" }
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-winphone81")
		end

		if "winstore81" == _OPTIONS["vs"] then
			premake.vstudio.toolset = "v120"
			premake.vstudio.storeapp = "8.1"
			platforms { "ARM" }
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-winstore81")
		end

		if "winstore82" == _OPTIONS["vs"] then
			premake.vstudio.toolset = "v140"
			premake.vstudio.storeapp = "8.2"
			platforms { "ARM" }
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-winstore82")
		end

		if "intel-14" == _OPTIONS["vs"] then
			premake.vstudio.toolset = "Intel C++ Compiler XE 14.0"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-intel")
		end

		if "intel-15" == _OPTIONS["vs"] then
			premake.vstudio.toolset = "Intel C++ Compiler XE 15.0"
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-intel")
		end

		if ("vs2013-xp") == _OPTIONS["vs"] then
			premake.vstudio.toolset = ("v120_xp")
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-xp")
		end
		
		if ("vs2015-xp") == _OPTIONS["vs"] then
			premake.vstudio.toolset = ("v140_xp")
			location (_buildDir .. "projects/" .. _subDir .. "/".. _ACTION .. "-xp")
		end
	elseif _ACTION == "xcode4" then

		if "osx" == _OPTIONS["xcode"] then
			premake.xcode.toolset = "macosx"
			location (path.join(_buildDir, "projects", _ACTION .. "-osx"))

		elseif "ios" == _OPTIONS["xcode"] then
			premake.xcode.toolset = "iphoneos"
			location (path.join(_buildDir, "projects", _ACTION .. "-ios"))
		end
	end

	if (_OPTIONS["CC"] ~= nil) then
		premake.gcc.cc  = _OPTIONS["CC"]
	end
	if (_OPTIONS["CXX"] ~= nil) then
		premake.gcc.cxx  = _OPTIONS["CXX"]
	end
	if (_OPTIONS["LD"] ~= nil) then
		premake.gcc.ld  = _OPTIONS["LD"]
	end

	configuration {} -- reset configuration


	configuration { "x32", "vs*" }
		objdir (_buildDir .. _ACTION .. "/obj")

	configuration { "x32", "vs*", "Release" }
		targetdir (_buildDir .. _ACTION .. "/bin/x32/Release")

	configuration { "x32", "vs*", "Debug" }
		targetdir (_buildDir .. _ACTION .. "/bin/x32/Debug")

	configuration { "x64", "vs*" }
		defines { "_WIN64" }
		objdir (_buildDir .. _ACTION .. "/obj")

	configuration { "x64", "vs*", "Release" }
		targetdir (_buildDir .. _ACTION .. "/bin/x64/Release")

	configuration { "x64", "vs*", "Debug" }
		targetdir (_buildDir .. _ACTION .. "/bin/x64/Debug")

	configuration { "ARM", "vs*" }
		targetdir (_buildDir .. _ACTION .. "/bin/ARM")
		objdir (_buildDir .. _ACTION .. "/obj")

	configuration { "ARM", "vs*", "Release" }
		targetdir (_buildDir .. _ACTION .. "/bin/ARM/Release")

	configuration { "ARM", "vs*", "Debug" }
		targetdir (_buildDir .. _ACTION .. "/bin/ARM/Debug")

	configuration { "x32", "vs*-clang" }
		objdir (_buildDir .. _ACTION .. "-clang/obj")

	configuration { "x32", "vs*-clang", "Release" }
		targetdir (_buildDir .. _ACTION .. "-clang/bin/x32/Release")

	configuration { "x32", "vs*-clang", "Debug" }
		targetdir (_buildDir .. _ACTION .. "-clang/bin/x32/Debug")

	configuration { "x64", "vs*-clang" }
		objdir (_buildDir .. _ACTION .. "-clang/obj")

	configuration { "x64", "vs*-clang", "Release" }
		targetdir (_buildDir .. _ACTION .. "-clang/bin/x64/Release")

	configuration { "x64", "vs*-clang", "Debug" }
		targetdir (_buildDir .. _ACTION .. "-clang/bin/x64/Debug")

	configuration { "vs*-clang" }
		buildoptions {
			"-Qunused-arguments",
		}

	configuration { "winphone8* or winstore8*" }
		removeflags {
			"StaticRuntime",
			"NoExceptions",
			"EnableMinimalRebuild",
		}

	configuration { "mingw*" }
		defines { "WIN32" }

	configuration { "x32", "mingw32-gcc" }
		objdir (_buildDir .. "mingw-gcc" .. "/obj")
		buildoptions { "-m32" }

	configuration { "x32", "mingw32-gcc", "Release" }
		targetdir (_buildDir .. "mingw-gcc" .. "/bin/x32/Release")

	configuration { "x32", "mingw32-gcc", "Debug" }
		targetdir (_buildDir .. "mingw-gcc" .. "/bin/x32/Debug")

	configuration { "x64", "mingw64-gcc" }
		objdir (_buildDir .. "mingw-gcc" .. "/obj")
		buildoptions { "-m64" }

	configuration { "x64", "mingw64-gcc", "Release" }
		targetdir (_buildDir .. "mingw-gcc" .. "/bin/x64/Release")

	configuration { "x64", "mingw64-gcc", "Debug" }
		targetdir (_buildDir .. "mingw-gcc" .. "/bin/x64/Debug")

	configuration { "steamlink" }
		objdir ( _buildDir .. "steamlink/obj")
		defines {
			"__STEAMLINK__=1", -- There is no special prefedined compiler symbol to detect SteamLink, faking it.
		}
		buildoptions {
			"-marm",
			"-mfloat-abi=hard",
			"--sysroot=$(MARVELL_SDK_PATH)/rootfs",
		}
		linkoptions {
			"-static-libgcc",
			"-static-libstdc++",
			"--sysroot=$(MARVELL_SDK_PATH)/rootfs",
		}

	configuration { "steamlink", "Release" }
		targetdir (_buildDir .. "steamlink/bin/Release")

	configuration { "steamlink", "Debug" }
		targetdir (_buildDir .. "steamlink/bin/Debug")

	configuration { "mingw-clang" }
		linkoptions {
			"-Wl,--allow-multiple-definition",
		}

	configuration { "x32", "mingw-clang" }
		objdir ( _buildDir .. "mingw-clang/obj")
		buildoptions { "-m32" }

	configuration { "x32", "mingw-clang", "Release" }
		targetdir (_buildDir .. "mingw-clang/bin/x32/Release")

	configuration { "x32", "mingw-clang", "Debug" }
		targetdir (_buildDir .. "mingw-clang/bin/x32/Debug")

	configuration { "x64", "mingw-clang" }
		objdir (_buildDir .. "mingw-clang/obj")
		buildoptions { "-m64" }

	configuration { "x64", "mingw-clang", "Release" }
		targetdir (_buildDir .. "mingw-clang/bin/x64/Release")

	configuration { "x64", "mingw-clang", "Debug" }
		targetdir (_buildDir .. "mingw-clang/bin/x64/Debug")

	configuration { "linux-gcc", "x32" }
		objdir (_buildDir .. "linux_gcc" .. "/obj")
		buildoptions {
			"-m32",
		}

	configuration { "linux-gcc", "x32", "Release" }
		targetdir (_buildDir .. "linux_gcc" .. "/bin/x32/Release")

	configuration { "linux-gcc", "x32", "Debug" }
		targetdir (_buildDir .. "linux_gcc" .. "/bin/x32/Debug")

	configuration { "linux-gcc", "x64" }
		objdir (_buildDir .. "linux_gcc" .. "/obj")
		buildoptions {
			"-m64",
		}

	configuration { "linux-gcc", "x64", "Release" }
		targetdir (_buildDir .. "linux_gcc" .. "/bin/x64/Release")

	configuration { "linux-gcc", "x64", "Debug" }
		targetdir (_buildDir .. "linux_gcc" .. "/bin/x64/Debug")

	configuration { "linux-clang", "x32" }
		objdir (_buildDir .. "linux_clang" .. "/obj")
		buildoptions {
			"-m32",
		}

	configuration { "linux-clang", "x32", "Release" }
		targetdir (_buildDir .. "linux_clang" .. "/bin/x32/Release")

	configuration { "linux-clang", "x32", "Debug" }
		targetdir (_buildDir .. "linux_clang" .. "/bin/x32/Debug")

	configuration { "linux-clang", "x64" }
		objdir (_buildDir .. "linux_clang" .. "/obj")
		buildoptions {
			"-m64",
		}

	configuration { "linux-clang", "x64", "Release" }
		targetdir (_buildDir .. "linux_clang" .. "/bin/x64/Release")

	configuration { "linux-clang", "x64", "Debug" }
		targetdir (_buildDir .. "linux_clang" .. "/bin/x64/Debug")

	configuration { "solaris", "x32" }
		objdir (_buildDir .. "solaris" .. "/obj")
		buildoptions {
			"-m32",
		}

	configuration { "solaris", "x32", "Release" }
		targetdir (_buildDir .. "solaris" .. "/bin/x32/Release")

	configuration { "solaris", "x32", "Debug" }
		targetdir (_buildDir .. "solaris" .. "/bin/x32/Debug")

	configuration { "solaris", "x64" }
		objdir (_buildDir .. "solaris" .. "/obj")
		buildoptions {
			"-m64",
		}

	configuration { "solaris", "x64", "Release" }
		targetdir (_buildDir .. "solaris" .. "/bin/x64/Release")

	configuration { "solaris", "x64", "Debug" }
		targetdir (_buildDir .. "solaris" .. "/bin/x64/Debug")

	configuration { "freebsd", "x32" }
		objdir (_buildDir .. "freebsd" .. "/obj")
		buildoptions {
			"-m32",
		}

	configuration { "freebsd", "x32", "Release" }
		targetdir (_buildDir .. "freebsd" .. "/bin/x32/Release")

	configuration { "freebsd", "x32", "Debug" }
		targetdir (_buildDir .. "freebsd" .. "/bin/x32/Debug")

	configuration { "freebsd", "x64" }
		objdir (_buildDir .. "freebsd" .. "/obj")
		buildoptions {
			"-m64",
		}
	configuration { "freebsd", "x64", "Release" }
		targetdir (_buildDir .. "freebsd" .. "/bin/x64/Release")

	configuration { "freebsd", "x64", "Debug" }
		targetdir (_buildDir .. "freebsd" .. "/bin/x64/Debug")

	configuration { "netbsd", "x32" }
		objdir (_buildDir .. "netbsd" .. "/obj")
		buildoptions {
			"-m32",
		}
	configuration { "netbsd", "x32", "Release" }
		targetdir (_buildDir .. "netbsd" .. "/bin/x32/Release")

	configuration { "netbsd", "x32", "Debug" }
		targetdir (_buildDir .. "netbsd" .. "/bin/x32/Debug")

	configuration { "netbsd", "x64" }
		objdir (_buildDir .. "netbsd" .. "/obj")
		buildoptions {
			"-m64",
		}
	configuration { "netbsd", "x64", "Release" }
		targetdir (_buildDir .. "netbsd" .. "/bin/x64/Release")

	configuration { "netbsd", "x64", "Debug" }
		targetdir (_buildDir .. "netbsd" .. "/bin/x64/Debug")

	configuration { "android-*" }
		includedirs {
			MAME_DIR .. "3rdparty/bgfx/3rdparty/khronos",
			"$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/libcxx/include",
			"$(ANDROID_NDK_ROOT)/sources/android/support/include",
			"$(ANDROID_NDK_ROOT)/sources/android/native_app_glue",
		}
		linkoptions {
			"-static-libgcc",
		}
		flags {
			"NoImportLib",
		}
		links {
			"c",
			"dl",
			"m",
			"android",
			"log",
			"gcc",
		}
		buildoptions {
			"-fpic",
			"-ffunction-sections",
			"-funwind-tables",
			"-fstack-protector-strong",
			"-no-canonical-prefixes",
			"-fno-integrated-as",
			"-Wunused-value",
			"-Wundef",
			"-Wno-cast-align",
		}
		linkoptions {
			"-no-canonical-prefixes",
			"-Wl,--no-undefined",
			"-Wl,-z,noexecstack",
			"-Wl,-z,relro",
			"-Wl,-z,now",
		}


	configuration { "android-arm" }
		targetdir (_buildDir .. "android-arm" .. "/bin")
		objdir (_buildDir .. "android-arm" .. "/obj")
			libdirs {
				"$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a",
				"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-arm/usr/lib",
			}
			includedirs {
				"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-arm/usr/include",
			}
			buildoptions {
				"-gcc-toolchain $(ANDROID_NDK_ARM)",
				"-target armv7-none-linux-androideabi",
				"-march=armv7-a",
				"-mfloat-abi=softfp",
				"-mfpu=vfpv3-d16",
				"-mthumb",
			}
			linkoptions {
				"-gcc-toolchain $(ANDROID_NDK_ARM)",
				"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-arm/usr/lib/crtbegin_so.o",
				"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-arm/usr/lib/crtend_so.o",
				"-target armv7-none-linux-androideabi",
				"-march=armv7-a",
				"-mthumb",
			}

	configuration { "android-mips" }
		targetdir (_buildDir .. "android-mips" .. "/bin")
		objdir (_buildDir .. "android-mips" .. "/obj")
		libdirs {
			"$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/libs/mips",
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-mips/usr/lib/",
		}
		includedirs {
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-mips/usr/include",
		}
		buildoptions {
			"-gcc-toolchain $(ANDROID_NDK_MIPS)",
			"-target mipsel-none-linux-android",
		}
		linkoptions {
			"-gcc-toolchain $(ANDROID_NDK_MIPS)",
			"-target mipsel-none-linux-android",
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-mips/usr/lib/crtbegin_so.o",
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-mips/usr/lib/crtend_so.o",
		}

	configuration { "android-x86" }
		targetdir (_buildDir .. "android-x86" .. "/bin")
		objdir (_buildDir .. "android-x86" .. "/obj")
		libdirs {
			"$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/libs/x86",
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-x86/usr/lib",
		}
		includedirs {
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-x86/usr/include",
		}
		buildoptions {
			"-gcc-toolchain $(ANDROID_NDK_X86)",
			"-target i686-none-linux-android",
			"-mssse3"
		}
		linkoptions {
			"-gcc-toolchain $(ANDROID_NDK_X86)",
			"-target i686-none-linux-android",
			"-mssse3",
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-x86/usr/lib/crtbegin_so.o",
			"$(ANDROID_NDK_ROOT)/platforms/" .. androidPlatform .. "/arch-x86/usr/lib/crtend_so.o",
		}


	configuration { "asmjs" }
		targetdir (_buildDir .. "asmjs" .. "/bin")
		objdir (_buildDir .. "asmjs" .. "/obj")
		includedirs {
			"$(EMSCRIPTEN)/system/include",
			"$(EMSCRIPTEN)/system/include/compat",
			"$(EMSCRIPTEN)/system/include/libc",
			"$(EMSCRIPTEN)/system/lib/libcxxabi/include",
		}
		buildoptions {
			"-Wno-cast-align",
			"-Wno-tautological-compare",
			"-Wno-self-assign-field",
			"-Wno-format-security",
			"-Wno-inline-new-delete",
			"-Wno-constant-logical-operand",
			"-Wno-absolute-value",
			"-Wno-unknown-warning-option",
			"-Wno-extern-c-compat",
		}

	configuration { "pnacl" }
		buildoptions {
			"-U__STRICT_ANSI__", -- strcasecmp, setenv, unsetenv,...
			"-fno-stack-protector",
			"-fdiagnostics-show-option",
			"-fdata-sections",
			"-ffunction-sections",
			"-Wunused-value",
		}
	
	configuration { "pnacl" }
		buildoptions {
			"-Wno-tautological-undefined-compare",
			"-Wno-cast-align",
		}
		includedirs {
			"$(NACL_SDK_ROOT)/include",
			"$(NACL_SDK_ROOT)/include/pnacl",
		}

	configuration { "pnacl" }
		targetdir (_buildDir .. "pnacl" .. "/bin")
		objdir (_buildDir .. "pnacl" .. "/obj")

	configuration { "pnacl", "Debug" }
		libdirs { "$(NACL_SDK_ROOT)/lib/pnacl/Debug" }

	configuration { "pnacl", "Release" }
		libdirs { "$(NACL_SDK_ROOT)/lib/pnacl/Release" }

	configuration { "osx*", "x32" }
		objdir (_buildDir .. "osx_clang" .. "/obj")
		buildoptions {
			"-m32",
		}
	configuration { "osx*", "x32", "Release" }
		targetdir (_buildDir .. "osx_clang" .. "/bin/x32/Release")

	configuration { "osx*", "x32", "Debug" }
		targetdir (_buildDir .. "osx_clang" .. "/bin/x32/Debug")

	configuration { "osx*", "x64" }
		objdir (_buildDir .. "osx_clang" .. "/obj")
		buildoptions {
			"-m64",
		}

	configuration { "osx*", "x64", "Release" }
		targetdir (_buildDir .. "osx_clang" .. "/bin/x64/Release")

	configuration { "osx*", "x64", "Debug" }
		targetdir (_buildDir .. "osx_clang" .. "/bin/x64/Debug")

	configuration { "ios-arm" }
		targetdir (_buildDir .. "ios-arm" .. "/bin")
		objdir (_buildDir .. "ios-arm" .. "/obj")

	configuration { "ios-simulator" }
		targetdir (_buildDir .. "ios-simulator" .. "/bin")
		objdir (_buildDir .. "ios-simulator" .. "/obj")

	configuration { "qnx-arm" }
		targetdir (_buildDir .. "qnx-arm" .. "/bin")
		objdir (_buildDir .. "qnx-arm" .. "/obj")

	configuration { "rpi" }
		targetdir (_buildDir .. "rpi" .. "/bin")
		objdir (_buildDir .. "rpi" .. "/obj")

	configuration { "os2" }
		objdir (_buildDir .. "os2" .. "/obj")

	configuration { "os2", "Release" }
		targetdir (_buildDir .. "os2" .. "/bin/Release")

	configuration { "os2", "Debug" }
		targetdir (_buildDir .. "os2" .. "/bin/Debug")

	configuration {} -- reset configuration

	return true
end

function strip()
	if _OPTIONS["STRIP_SYMBOLS"]~="1" then
		return true
	end

	configuration { "osx-*", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) " .. (_OPTIONS['TOOLCHAIN'] and toolchainPrefix) .. "strip \"$(TARGET)\"",
		}

	configuration { "android-arm", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) $(ANDROID_NDK_ARM)/bin/arm-linux-androideabi-strip -s \"$(TARGET)\""
		}

	configuration { "android-mips", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) $(ANDROID_NDK_MIPS)/bin/mipsel-linux-android-strip -s \"$(TARGET)\""
		}

	configuration { "android-x86", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) $(ANDROID_NDK_X86)/bin/i686-linux-android-strip -s \"$(TARGET)\""
		}

	configuration { "linux-* or rpi", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) strip -s \"$(TARGET)\""
		}

	configuration { "mingw*", "x64", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) " .. (_OPTIONS['TOOLCHAIN'] and toolchainPrefix or "$(MINGW64)/bin/") .. "strip -s \"$(TARGET)\"",
		}
	configuration { "mingw*", "x32", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) " .. (_OPTIONS['TOOLCHAIN'] and toolchainPrefix or "$(MINGW32)/bin/") .. "strip -s \"$(TARGET)\"",
		}

	configuration { "pnacl" }
		postbuildcommands {
			"$(SILENT) echo Running pnacl-finalize.",
			"$(SILENT) " .. naclToolchain .. "finalize \"$(TARGET)\""
		}

	configuration { "asmjs" }
		postbuildcommands {
			"$(SILENT) echo Running asmjs finalize.",
			"$(SILENT) $(EMSCRIPTEN)/emcc -O2 -s TOTAL_MEMORY=268435456 \"$(TARGET)\" -o \"$(TARGET)\".html"
			-- ALLOW_MEMORY_GROWTH
		}

	configuration { "os2", "Release" }
		postbuildcommands {
			"$(SILENT) echo Stripping symbols.",
			"$(SILENT) lxlite /B- /L- /CS \"$(TARGET)\""
		}

	configuration {} -- reset configuration
end

