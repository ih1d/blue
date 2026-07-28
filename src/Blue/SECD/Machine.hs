-- | Build 1: the reference SECD machine.  @step@ is the executable
-- spec every later artifact is tested against.
module Blue.SECD.Machine (Machine, step, run) where

data Machine = Machine

step :: Machine -> Machine
step = error "Blue.SECD.Machine.step: TODO (Build 1)"

run :: Machine -> Machine
run = error "Blue.SECD.Machine.run: TODO (Build 1)"
