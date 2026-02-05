{ mesa
, fetchFromGitLab
, lib
}:

(mesa.override {
  galliumDrivers = [ "freedreno" "llvmpipe" ];
  vulkanDrivers = [ "freedreno" ];
}).overrideAttrs (oldAttrs: {
  pname = "mesa-git";
  version = "unstable-2026-02-05";
  
  outputs = [ "out" "dev" "opencl" ];
  
  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mesa";
    repo = "mesa";
    rev = "main";
    hash = "sha256-M3bAHOs1m/i4baPHMsk8sbDa3gXz//6tsSSALlRcYrM=";
  };
  
  # Remove patches that are already applied in git or conflict
  patches = builtins.filter (patch: 
    # Keep patches that don't contain "llvm" in their name (the LLVM 21 patch is already applied)
    !(lib.hasInfix "llvm" (builtins.toString patch))
  ) (oldAttrs.patches or []);
  
  # Disable stuff that isnt needed
  mesonFlags = 
    (builtins.filter (flag: 
      !(lib.hasPrefix "-Dgallium-drivers=" flag) &&
      !(lib.hasPrefix "-Dvulkan-drivers=" flag) &&
      !(lib.hasPrefix "-Dauto_features=" flag) &&
      !(lib.hasPrefix "-Dtools=" flag) &&
      !(lib.hasPrefix "-Dinstall-mesa-clc=" flag) &&
      !(lib.hasPrefix "-Dinstall-precomp-compiler=" flag) &&
      !(lib.hasPrefix "-Dgallium-rusticl" flag)  # Remove all rusticl flags
    ) oldAttrs.mesonFlags) ++ [
      "-Dauto_features=auto"
      "-Dgallium-drivers=freedreno,llvmpipe"
      "-Dvulkan-drivers=freedreno"
      "-Dtools="
      "-Dinstall-mesa-clc=false"
      "-Dinstall-precomp-compiler=false"
      "-Dgallium-rusticl=false"
    ];
})
