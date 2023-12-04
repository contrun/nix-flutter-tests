{
description = "Flutter 3.13.x";
inputs = {
  nixpkgs.url = "nixpkgs/nixos-unstable";
  flake-utils.url = "github:numtide/flake-utils";
};
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      # special version for aapt2 (usually latest available)
      buildToolsVersionForAapt2 = "34.0.0-rc4";
      # Installing android sdk
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        # Installing both version for aapt2 and version that flutter wants
        buildToolsVersions = [ buildToolsVersionForAapt2 "30.0.3" ];
        platformVersions = [ "33" "28" ];
        abiVersions = [ "armeabi-v7a" "arm64-v8a" "x86_64" ];
        includeEmulator = true;
        includeSystemImages = true;
        emulatorVersion = "34.1.9";
      };
      androidSdk = androidComposition.androidsdk;
    in
    {
      devShell =
        with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          # specify gradle the aapt2 executable
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/34.0.0-rc4/aapt2";
          buildInputs = [
            flutter

            androidSdk
            jdk17

            xorg.libX11
          ];
        };
    });
}
