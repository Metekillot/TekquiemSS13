import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { Beaker, BeakerDisplay } from './common/BeakerDisplay';

type Data = {
  amount: number;
  purity: number;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: { name: string; volume: number }[];
};

export const ChemDebugSynthesizer = (props) => {
  const { act, data } = useBackend<Data>();
  const { amount, purity, beaker } = data;

  return (
    <Window width={390} height={330}>
      <Window.Content scrollable>
        <Section
          title="Recipient"
          buttons={
            isBeakerLoaded ? (
              <>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('ejectBeaker')}
                />
                <NumberInput
                  value={amount}
                  unit="u"
                  minValue={1}
                  maxValue={beakerMaxVolume}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) =>
                    act('amount', {
                      amount: value,
                    })
                  }
                />
                <NumberInput
                  value={purity}
                  unit="%"
                  minValue={0}
                  maxValue={120}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) =>
                    act('purity', {
                      amount: value,
                    })
                  }
                />
                <Button
                  icon="plus"
                  content="Input"
                  onClick={() => act('input')}
                />
              </>
            ) : (
              <Button
                icon="plus"
                content="Create Beaker"
                onClick={() => act('makecup')}
              />
            )
          }
        >
          <BeakerDisplay beaker={beaker} showpH />
        </Section>
      </Window.Content>
    </Window>
  );
};
