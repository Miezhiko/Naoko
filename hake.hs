{-# LANGUAGE MultiWayIf    #-}
{-# LANGUAGE UnicodeSyntax #-}

import           Hake

main ∷ IO ()
main = hake $ do

  "clean | clean the project" ∫
    cargo ["clean"] ?> removeDirIfExists targetPath

  "update | update dependencies" ∫ cargo ["update"]

  naokoExecutable ♯
    cargo <| "build" : buildFlagsNaoko False

  "install | install to system" ◉ [ "fat" ] ∰
    cargo <| "install" : buildFlagsNaoko True

  "test | build and test" ◉ [naokoExecutable] ∰ do
    cargo ["test"]
    cargo ["clippy"]

  "restart | restart services" ◉ [ naokoExecutable ] ∰
    systemctl ["restart", appNameNaoko]

  "run | run Naoko" ◉ [ naokoExecutable ] ∰ do
    cargo . (("run" : buildFlagsNaoko False) ++) . ("--" :) =<< getHakeArgs

 where
  appNameNaoko ∷ String
  appNameNaoko = "naoko"

  targetPath ∷ FilePath
  targetPath = "target"

  buildPath ∷ FilePath
  buildPath = targetPath </> "release"

  fatArgs ∷ [String]
  fatArgs = [ "--profile"
            , "fat-release" ]

  buildFlagsNaoko ∷ Bool -> [String]
  buildFlagsNaoko fat =
    let defaultFlags = [ "-p", appNameNaoko
                       , "--release" ]
    in if fat then defaultFlags ++ fatArgs
              else defaultFlags

  naokoExecutable ∷ FilePath
  naokoExecutable = buildPath </> appNameNaoko
