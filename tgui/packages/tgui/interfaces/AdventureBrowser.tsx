import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { formatTime } from '../format';
import { Window } from '../layouts';
import { AdventureDataProvider, AdventureScreen } from './ExodroneConsole';

type Adventure = {
  ref: string;
  name: string;
  id: string;
  approved: boolean;
  uploader: string;
  version: number;
  timestamp: string;
  json_status: string;
};

type AdventureBrowserData = AdventureDataProvider & {
  adventures: Array<Adventure>;
  feedback_message: string;
  play_mode: boolean;
  adventure_data: any;
  delay_time: number;
  delay_message: string;
};

const AdventureList = (props) => {
  const { data, act } = useBackend<AdventureBrowserData>();
  const [openAdventure, setOpenAdventure] = useLocalState<string | null>(
    'openAdventure',
    null,
  );

  return (
    <>
      {openAdventure && (
        <AdventureEntry
          entry_ref={openAdventure}
          close={() => setOpenAdventure(null)}
        />
      )}
      {!openAdventure && (
        <Table>
          <Table.Row>
            <Table.Cell color="label">ID</Table.Cell>
            <Table.Cell color="label">Title</Table.Cell>
            <Table.Cell color="label">Edit</Table.Cell>
          </Table.Row>
          {data.adventures.map((adventure) => (
            <Table.Row key={adventure.ref} className="candystripe">
              <Table.Cell>{adventure.id}</Table.Cell>
              <Table.Cell>{adventure.name}</Table.Cell>
              <Table.Cell>
                <Button
                  icon="edit"
                  onClick={() => setOpenAdventure(adventure.ref)}
                />
              </Table.Cell>
            </Table.Row>
          ))}
          <Table.Row>
            <Button onClick={() => act('create')}>Create New</Button>
          </Table.Row>
        </Table>
      )}
    </>
  );
};

const DebugPlayer = (props) => {
  const { data, act } = useBackend<AdventureBrowserData>();
  return (
    <Section
      title="Playtest"
      buttons={<Button onClick={() => act('end_play')}>End Playtest</Button>}
    >
      {data.delay_time > 0 ? (
        <Box>
          DELAY {formatTime(data.delay_time)} / {data.delay_message}
        </Box>
      ) : (
        <AdventureScreen
          adventure_data={data.adventure_data}
          drone_integrity={100}
          drone_max_integrity={100}
          hide_status
        />
      )}
    </Section>
  );
};

export const AdventureBrowser = (props) => {
  const { data } = useBackend<AdventureBrowserData>();

  return (
    <Window width={650} height={500} title="Adventure Manager">
      <Window.Content>
        {!!data.feedback_message && (
          <NoticeBox>{data.feedback_message}</NoticeBox>
        )}
        {data.play_mode ? <DebugPlayer /> : <AdventureList />}
      </Window.Content>
    </Window>
  );
};
