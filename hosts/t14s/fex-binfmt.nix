{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable FEX for automatic x86/x86_64 binary translation
  boot.binfmt.registrations = {
    # x86 (32-bit) support via FEX
    fex-x86 = {
      interpreter = "${pkgs.fex}/bin/FEXInterpreter";
      magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      fixBinary = true;
      wrapInterpreterInShell = false;
      matchCredentials = true;
      preserveArgvZero = false;
    };

    # x86_64 (64-bit) support via FEX
    fex-x86_64 = {
      interpreter = "${pkgs.fex}/bin/FEXInterpreter";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      fixBinary = true;
      wrapInterpreterInShell = false;
      matchCredentials = true;
      preserveArgvZero = false;
    };
  };
  environment.sessionVariables = {
  };
}
