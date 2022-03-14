pragma circom 2.0.0;

include "mimcsponge.circom";

template Pow2Merkle(n) {
  signal input leaves[n];
  signal output treeRoot;

  var intermediateNodes[n * 2 - 1];
  component leafHashers[n * 2 - 1];

  for (var i = 0; i < n; i++) {
    leafHashers[i] = MiMCSponge(1, 220, 1);
    leafHashers[i].ins[0] <== leaves[i];
    // require to prevent invalid access error, unsure what k does
    leafHashers[i].k <== 0;
    intermediateNodes[i] = leafHashers[i].outs[0];
  }

  var lastShift = 0;
  var shift = n;
  var currentLevelSize = n / 2;

  while (currentLevelSize > 0) {
    for (var i = 0; i < currentLevelSize; i++) {
      var currentIndex = i + shift;
      leafHashers[currentIndex] = MiMCSponge(2, 220, 1);
      leafHashers[currentIndex].ins[0] <== intermediateNodes[i * 2 + lastShift];
      leafHashers[currentIndex].ins[1] <== intermediateNodes[i * 2 + 1 + lastShift];
      // require to prevent invalid access error, unsure what k does
      leafHashers[currentIndex].k <== 0;
      intermediateNodes[currentIndex] = leafHashers[currentIndex].outs[0];
    }
    lastShift = shift;
    shift += currentLevelSize;
    currentLevelSize /= 2;
  }

  treeRoot <== intermediateNodes[n * 2 - 2];
}

component main {public [leaves]} = Pow2Merkle(8);
