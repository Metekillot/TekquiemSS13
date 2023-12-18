import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
};

export const AntagInfoBrother = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, brothers, objectives } = data;
  return (
    <Window width={620} height={250}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are the {antag_name} of {brothers}!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};
