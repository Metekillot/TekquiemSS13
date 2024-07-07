import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ChemDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const recording = !!data.recordingRecipe;
  const { recipeReagents = [], recipes = [], beaker } = data;
  const [hasCol, setHasCol] = useState(false);

  const beakerTransferAmounts = beaker ? beaker.transferAmounts : [];
  const recordedContents =
    recording &&
    Object.keys(data.recordingRecipe).map((id) => ({
      id,
      name: toTitleCase(id.replace(/_/, ' ')),
      volume: data.recordingRecipe[id],
    }));

  return (
    <Window width={565} height={620}>
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={
            <>
              {recording && (
                <Box inline mx={1} color="red">
                  <Icon name="circle" mr={1} />
                  Recording
                </Box>
              )}
              <Button
                icon="book"
                disabled={!data.isBeakerLoaded}
                content={'Reaction search'}
                tooltip={
                  data.isBeakerLoaded
                    ? 'Look up recipes and reagents!'
                    : 'Please insert a beaker!'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('reaction_lookup')}
              />
              <Button
                icon="cog"
                tooltip="Color code the reagents by pH"
                tooltipPosition="bottom-start"
                selected={hasCol}
                onClick={() => setHasCol(!hasCol)}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar value={data.energy / data.maxEnergy}>
                {toFixed(data.energy) + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Recipes"
          buttons={
            <>
              {!recording && (
                <Box inline mx={1}>
                  <Button
                    color="transparent"
                    content="Clear recipes"
                    onClick={() => act('clear_recipes')}
                  />
                </Box>
              )}
              {!recording && (
                <Button
                  icon="circle"
                  disabled={!data.isBeakerLoaded}
                  content="Record"
                  onClick={() => act('record_recipe')}
                />
              )}
              {recording && (
                <Button
                  icon="ban"
                  color="transparent"
                  content="Discard"
                  onClick={() => act('cancel_recording')}
                />
              )}
              {recording && (
                <Button
                  icon="save"
                  color="green"
                  content="Save"
                  onClick={() => act('save_recording')}
                />
              )}
            </>
          }
        >
          <Box mr={-1}>
            {recipes.map((recipe) => (
              <Button
                key={recipe.name}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={recipe.name}
                onClick={() =>
                  act('dispense_recipe', {
                    recipe: recipe.name,
                  })
                }
              />
            ))}
            {recipes.length === 0 && <Box color="light-gray">No recipes.</Box>}
          </Box>
        </Section>
        <Section
          title="Dispense"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}
        >
          <Box mr={-1}>
            {data.chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={chemical.title}
                tooltip={'pH: ' + chemical.pH}
                backgroundColor={
                  recipeReagents.includes(chemical.id)
                    ? hasCol
                      ? 'black'
                      : 'green'
                    : hasCol
                      ? chemical.pHCol
                      : 'default'
                }
                onClick={() =>
                  act('dispense', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
        <Section
          title="Beaker"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="minus"
              disabled={recording}
              content={amount}
              onClick={() => act('remove', { amount })}
            />
          ))}
        >
          <BeakerDisplay
            beaker={beaker}
            title_label={recording && 'Virtual beaker'}
            replace_contents={recordedContents}
            showpH={data.showpH}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
