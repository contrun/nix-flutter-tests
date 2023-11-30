{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {pkgs, system, ...}: {
        devShells.default = 
        let 
         pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
        buildToolsVersionForAapt2 = "34.0.0-rc4";

         android = pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "33.0.3";
          buildToolsVersions = [ buildToolsVersionForAapt2 ];
          includeEmulator = false;
          emulatorVersion = "34.1.9";
          platformVersions = [ "28" "29" "30" "31" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          cmakeVersions = [ "3.10.2" ];
          includeNDK = true;
          ndkVersions = [ "22.0.7026061" ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        extraLicenses = [
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "android-sdk-license"
          "android-sdk-preview-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"            
       ];
        };
              androidSdk = android.androidsdk;
        in
        pkgs.mkShell {
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersionForAapt2}/aapt2";
          NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1;
          ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
          LD_LIBRARY_PATH="${pkgs.glibc}/lib";
          buildInputs = with pkgs; [
               flutter

            androidSdk
            jdk17

            xorg.libX11
         
              ];
        };
        formatter = pkgs.alejandra;
      };
    };
}