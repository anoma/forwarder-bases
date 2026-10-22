| src/NativeTokenReceiver.sol:NativeTokenReceiver Contract |                 |      |        |       |         |
|----------------------------------------------------------|-----------------|------|--------|-------|---------|
| Deployment Cost                                          | Deployment Size |      |        |       |         |
|                                                        0 |              81 |      |        |       |         |
|                                                          |                 |      |        |       |         |
| Function Name                                            | Min             | Avg  | Median | Max   | # Calls |
| receive                                                  |               0 | 7482 |      0 | 22446 |       3 |

| src/SweepableNativeTokenReceiver.sol:SweepableNativeTokenReceiver Contract |                 |       |        |       |         |
|----------------------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                                            | Deployment Size |       |        |       |         |
|                                                                          0 |             922 |       |        |       |         |
|                                                                            |                 |       |        |       |         |
| Function Name                                                              | Min             | Avg   | Median | Max   | # Calls |
| receive                                                                    |               0 |  7492 |      0 | 22476 |       3 |
| sweep                                                                      |           21800 | 39511 |  34301 | 58078 |       5 |

| src/TransientFallbackHandler.sol:TransientFallbackHandler Contract |                 |      |        |      |         |
|--------------------------------------------------------------------|-----------------|------|--------|------|---------|
| Deployment Cost                                                    | Deployment Size |      |        |      |         |
|                                                                  0 |            1089 |      |        |      |         |
|                                                                    |                 |      |        |      |         |
| Function Name                                                      | Min             | Avg  | Median | Max  | # Calls |
| fallback                                                           |            3316 | 3316 |   3316 | 3316 |     256 |
| lookupMagicNumber                                                  |             392 |  392 |    392 |  392 |       3 |
| registerSelector                                                   |             404 |  404 |    404 |  404 |     260 |

| test/examples/ForwarderExample.sol:ForwarderExample Contract |                 |       |        |       |         |
|--------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                              | Deployment Size |       |        |       |         |
|                                                       356358 |            1667 |       |        |       |         |
|                                                              |                 |       |        |       |         |
| Function Name                                                | Min             | Avg   | Median | Max   | # Calls |
| forwardCall                                                  |           24620 | 28910 |  29755 | 31891 |       6 |
| getLogicRef                                                  |             180 |   180 |    180 |   180 |       1 |
| getProtocolAdapter                                           |             167 |   167 |    167 |   167 |       1 |

| test/examples/ForwarderUpgradeableExample.sol:ForwarderUpgradeableExample Contract |                 |       |        |       |         |
|------------------------------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                                                    | Deployment Size |       |        |       |         |
|                                                                             968494 |            4382 |       |        |       |         |
|                                                                                    |                 |       |        |       |         |
| Function Name                                                                      | Min             | Avg   | Median | Max   | # Calls |
| UPGRADE_INTERFACE_VERSION                                                          |             578 |   578 |    578 |   578 |       1 |
| forwardCall                                                                        |             404 |  8139 |   9010 | 13376 |       7 |
| getImplementation                                                                  |             383 |   383 |    383 |   383 |       1 |
| getLogicRef                                                                        |            2421 |  2421 |   2421 |  2421 |       1 |
| getProtocolAdapter                                                                 |            2273 |  2273 |   2273 |  2273 |       1 |
| initialize                                                                         |            2803 | 79279 |  92507 | 92507 |      24 |
| upgradeToAndCall                                                                   |            2917 | 13799 |  17427 | 17427 |       4 |

