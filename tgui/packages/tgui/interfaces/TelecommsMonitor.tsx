import { useMemo, useState } from 'react';
import {
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

enum Screen {
  Main,
  Machine,
}

type Data = {
  screen: Screen;
  network: string;
  error_message: string;
  machinery: Machine[];
  machine: Machine;
};

type Machine = {
  ref: string;
  id: string;
  name: string;
  linked_machinery: LinkedMachinery[];
};

type LinkedMachinery = {
  ref: string;
  id: string;
  name: string;
};

const MachineScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { network, machine } = data;
  const { linked_machinery = [] } = machine;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title="Entity Information"
          buttons={
            <Button
              content="Main Menu"
              icon="home"
              onClick={() => act('return_home')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Network">{network}</LabeledList.Item>
            <LabeledList.Item label="Network Entity">
              {machine.name}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Linked Entities">
          <Table>
            <Table.Row header>
              <Table.Cell>Address</Table.Cell>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Machine</Table.Cell>
            </Table.Row>
            {linked_machinery?.map((lm) => (
              <Table.Row key={lm.ref} className="candystripe">
                <Table.Cell>{lm.ref}</Table.Cell>
                <Table.Cell>{lm.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={lm.name}
                    onClick={() => act('view_machine', { id: lm.id })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MainScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { machinery = [], network } = data;
  const [networkId, setNetworkId] = useState(network);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Input
            value={networkId}
            onChange={(e, value) => setNetworkId(value)}
            placeholder="Network ID"
          />
          <Button
            onClick={() => act('probe_network', { network_id: networkId })}
          >
            Probe Network
          </Button>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Detected Network Entities"
          buttons={
            <Button
              content="Flush Buffer"
              icon="trash"
              color="red"
              disabled={machinery.length === 0}
              onClick={() => act('flush_buffer')}
            />
          }
        >
          <Table>
            <Table.Row header>
              <Table.Cell>Address</Table.Cell>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Machine</Table.Cell>
            </Table.Row>
            {machinery?.map((machine) => (
              <Table.Row key={machine.ref} className="candystripe">
                <Table.Cell>{machine.ref}</Table.Cell>
                <Table.Cell>{machine.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={machine.name}
                    onClick={() => act('view_machine', { id: machine.id })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const TelecommsMonitor = (props) => {
  const { act, data } = useBackend<Data>();
  const { screen, error_message } = data;
  return (
    <Window width={575} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {!!error_message && <NoticeBox>{error_message}</NoticeBox>}
          </Stack.Item>
          <Stack.Item grow>
            {(screen === Screen.Main && <MainScreen />) ||
              (screen === Screen.Machine && <MachineScreen />)}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainScreen = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { network, machines = [] } = data;

  const [networkId, setNetworkId] = useState(network);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill>
          <Stack fill>
            <Stack.Item grow>
              <Input
                fluid
                value={networkId}
                onChange={setNetworkId}
                placeholder="Enter Network ID..."
                onEnter={() => act('probe', { id: networkId })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('probe', { id: networkId })}>
                Probe Network
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <MachineList
          title="Detected Network Entities"
          buttons={
            <Button
              icon="trash"
              color="red"
              tooltip="Flush Buffer"
              disabled={machines.length === 0}
              onClick={() => act('flush')}
            />
          }
          machines={machines}
          onSelect={(machine) => act('view', { id: machine.id })}
        />
      </Stack.Item>
    </Stack>
  );
};

const MachineScreen = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { id, name, network, linkedMachines } = data.machine!;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title="Entity Information"
          buttons={
            <Button icon="home" onClick={() => act('home')}>
              Main Menu
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Network">{network}</LabeledList.Item>
            <LabeledList.Item label="Network ID">{id}</LabeledList.Item>
            <LabeledList.Item label="Network Entity">
              {toTitleCase(name)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <MachineList
          title="Linked Entities"
          machines={linkedMachines}
          onSelect={(machine) => act('view', { id: machine.id })}
        />
      </Stack.Item>
    </Stack>
  );
};

type MachineListProps = {
  title: string;
  buttons?: React.ReactNode;
  machines: Machine[];
  onSelect: (machine: Machine) => void;
};

const MachineList = (props: MachineListProps) => {
  const { title, buttons, machines, onSelect } = props;

  const [searching, setSearching] = useState(false);
  const [search, setSearch] = useState('');

  const sortedMachines = useMemo(
    () =>
      machines.filter((machine) =>
        machine.id.toLowerCase().includes(search.toLowerCase()),
      ),
    [search, machines.length],
  );

  return (
    <Section
      scrollable
      fill
      title={title}
      buttons={
        <>
          <Button
            icon="magnifying-glass"
            selected={searching}
            disabled={machines.length === 0}
            tooltip="Search by ID"
            onClick={() => setSearching(!searching)}
          />
          {buttons}
        </>
      }
    >
      {sortedMachines.length > 0 ? (
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack fill vertical>
              {sortedMachines.map((machine, index) => (
                <Stack.Item key={index}>
                  <Button
                    fluid
                    verticalAlignContent="middle"
                    tooltip={toTitleCase(machine.name)}
                    onClick={() => onSelect(machine)}
                  >
                    <Stack fill align="center">
                      <Stack.Item>
                        <Box
                          className={classes(['tcomms32x32', machine.icon])}
                        />
                      </Stack.Item>
                      <Stack.Item grow>{machine.id}</Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          {searching && (
            <Stack.Item height={2}>
              <Input
                mx={1}
                fluid
                autoFocus
                value={search}
                verticalAlign="middle"
                placeholder="Enter machine ID..."
                onChange={setSearch}
              />
            </Stack.Item>
          )}
        </Stack>
      ) : (
        <NoticeBox>No machines connected!</NoticeBox>
      )}
    </Section>
  );
};
