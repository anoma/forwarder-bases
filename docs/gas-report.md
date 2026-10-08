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
|                                                                          0 |             923 |       |        |       |         |
|                                                                            |                 |       |        |       |         |
| Function Name                                                              | Min             | Avg   | Median | Max   | # Calls |
| receive                                                                    |               0 |  7493 |      0 | 22479 |       3 |
| sweep                                                                      |           21800 | 39516 |  34310 | 58081 |       5 |

| src/TransientFallbackHandler.sol:TransientFallbackHandler Contract |                 |      |        |      |         |
|--------------------------------------------------------------------|-----------------|------|--------|------|---------|
| Deployment Cost                                                    | Deployment Size |      |        |      |         |
|                                                                  0 |            1090 |      |        |      |         |
|                                                                    |                 |      |        |      |         |
| Function Name                                                      | Min             | Avg  | Median | Max  | # Calls |
| fallback                                                           |            3319 | 3319 |   3319 | 3319 |     256 |
| lookupMagicNumber                                                  |             395 |  395 |    395 |  395 |       3 |
| registerSelector                                                   |             407 |  407 |    407 |  407 |     260 |

| test/examples/ForwarderExample.sol:ForwarderExample Contract |                 |       |        |       |         |
|--------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                              | Deployment Size |       |        |       |         |
|                                                       356574 |            1668 |       |        |       |         |
|                                                              |                 |       |        |       |         |
| Function Name                                                | Min             | Avg   | Median | Max   | # Calls |
| forwardCall                                                  |           24620 | 28914 |  29762 | 31897 |       6 |
| getLogicRef                                                  |             183 |   183 |    183 |   183 |       1 |
| getProtocolAdapter                                           |             170 |   170 |    170 |   170 |       1 |

| test/examples/ForwarderUpgradeableExample.sol:ForwarderUpgradeableExample Contract |                 |       |        |       |         |
|------------------------------------------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                                                    | Deployment Size |       |        |       |         |
|                                                                             968734 |            4383 |       |        |       |         |
|                                                                                    |                 |       |        |       |         |
| Function Name                                                                      | Min             | Avg   | Median | Max   | # Calls |
| UPGRADE_INTERFACE_VERSION                                                          |             581 |   581 |    581 |   581 |       1 |
| forwardCall                                                                        |             407 |  8144 |   9019 | 13382 |       7 |
| getImplementation                                                                  |             386 |   386 |    386 |   386 |       1 |
| getLogicRef                                                                        |            2424 |  2424 |   2424 |  2424 |       1 |
| getProtocolAdapter                                                                 |            2276 |  2276 |   2276 |  2276 |       1 |
| initialize                                                                         |            2806 | 79282 |  92510 | 92510 |      24 |
| upgradeToAndCall                                                                   |            2920 | 13807 |  17436 | 17436 |       4 |

