import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, NoticeBox, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';
import { AccessList } from './common/AccessList';

export const NtosCard = (props) => {
  return (
    <NtosWindow width={500} height={670}>
      <NtosWindow.Content scrollable>
        <NtosCardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCardContent = (props) => {
  const { act, data } = useBackend();
  const {
    authenticated,
    regions = [],
    access_on_card = [],
    jobs = {},
    id_rank,
    id_owner,
    has_id,
    have_printer,
    have_id_slot,
    wildcardSlots,
    wildcardFlags,
    trimAccess,
    accessFlags,
    accessFlagNames,
    showBasic,
    templates = {},
  } = data;

  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }

  const [selectedTab] = useSharedState(context, 'selectedTab', 'login');

  return (
    <>
      <Stack>
        <Stack.Item>
          <IDCardTabs />
        </Stack.Item>
        <Stack.Item width="100%">
          {(selectedTab === 'login' && <IDCardLogin />) ||
            (selectedTab === 'modify' && <IDCardTarget />)}
        </Stack.Item>
      </Stack>
      {!!has_id && !!authenticatedUser && (
        <Section
          title="Templates"
          mt={1}
          buttons={
            <Button
              icon="question-circle"
              tooltip={
                'Will attempt to apply all access for the template to the ID card.\n' +
                'Does not use wildcards unless the template specifies them.'
              }
              tooltipPosition="left"
            />
          }>
          <TemplateDropdown templates={templates} />
        </Section>
      )}
      <Stack mt={1}>
        <Stack.Item grow>
          {!!has_id && !!authenticatedUser && (
            <Box>
              <AccessList
                accesses={regions}
                selectedList={access_on_card}
                wildcardFlags={wildcardFlags}
                wildcardSlots={wildcardSlots}
                trimAccess={trimAccess}
                accessFlags={accessFlags}
                accessFlagNames={accessFlagNames}
                showBasic={!!showBasic}
                extraButtons={
                  <Button.Confirm
                    content="Terminate Employment"
                    confirmContent="Fire Employee?"
                    color="bad"
                    onClick={() => act('PRG_terminate')}
                  />
                }
                accessMod={(ref, wildcard) =>
                  act('PRG_access', {
                    access_target: ref,
                    access_wildcard: wildcard,
                  })
                }
              />
            </Box>
          )}
          {tab === 2 && (
            <Section
              title={id_rank}
              buttons={(
                <Button.Confirm
                  icon="exclamation-triangle"
                  content="Terminate"
                  color="bad"
                  onClick={() => act('PRG_terminate')} />
              )}>
              <Button.Input
                fluid
                content="Custom..."
                onCommit={(e, value) => act('PRG_assign', {
                  assign_target: 'Custom',
                  custom_name: value,
                })} />
              <Flex>
                <Flex.Item>
                  <Tabs vertical>
                    {Object.keys(jobs).map(department => (
                      <Tabs.Tab
                        key={department}
                        selected={department === selectedDepartment}
                        onClick={() => setSelectedDepartment(department)}>
                        {department}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Flex.Item>
                <Flex.Item grow={1}>
                  {departmentJobs.map(job => (
                    <Button
                      fluid
                      key={job.job}
                      content={job.display_name}
                      onClick={() => act('PRG_assign', {
                        assign_target: job.job,
                      })} />
                  ))}
                </Flex.Item>
              </Flex>
            </Section>
          )}
        </Box>
      )}
    </>
  );
};

const IdCardPage = (props) => {
  const { act, data } = useBackend();
  const {
    authenticatedUser,
    id_rank,
    id_owner,
    has_id,
    id_name,
    id_age,
    authIDName,
  } = data;

  return (
    <Section
      title="Login"
      buttons={
        <>
          <Button
            icon="print"
            content="Print"
            disabled={!have_printer || !has_id}
            onClick={() => act('PRG_print')}
          />
          <Button
            icon={authenticatedUser ? 'sign-out-alt' : 'sign-in-alt'}
            content={authenticatedUser ? 'Log Out' : 'Log In'}
            color={authenticatedUser ? 'bad' : 'good'}
            onClick={() => {
              act(authenticatedUser ? 'PRG_logout' : 'PRG_authenticate');
            }}
          />
        </>
      }>
      <Stack wrap="wrap">
        <Stack.Item width="100%">
          <Button
            fluid
            ellipsis
            icon="eject"
            content={authIDName}
            onClick={() => act('PRG_ejectauthid')}
          />
        </Stack.Item>
        <Stack.Item width="100%" mt={1} ml={0}>
          Login: {authenticatedUser || '-----'}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IDCardTarget = (props, context) => {
  const { act, data } = useBackend(context);
  const { authenticatedUser, id_rank, id_owner, has_id, id_name, id_age } =
    data;

  return (
    <Section title="Modify ID">
      <Button
        width="100%"
        ellipsis
        icon="eject"
        content={id_name}
        onClick={() => act('PRG_ejectmodid')}
      />
      {!!(has_id && authenticatedUser) && (
        <>
          <Stack mt={1}>
            <Stack.Item align="center">Details:</Stack.Item>
            <Stack.Item grow={1} mr={1} ml={1}>
              <Input
                width="100%"
                value={id_owner}
                onInput={(e, value) =>
                  act('PRG_edit', {
                    name: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                value={id_age || 0}
                unit="Years"
                minValue={17}
                maxValue={85}
                onChange={(e, value) => {
                  act('PRG_age', {
                    id_age: value,
                  });
                }}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item align="center">Assignment:</Stack.Item>
            <Stack.Item grow={1} ml={1}>
              <Input
                fluid
                mt={1}
                value={id_rank}
                onInput={(e, value) =>
                  act('PRG_assign', {
                    assignment: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </>
      )}
    </Section>
  );
};

const TemplateDropdown = (props) => {
  const { act } = useBackend();
  const { templates } = props;

  const templateKeys = Object.keys(templates);

  if (!templateKeys.length) {
    return;
  }

  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          width="100%"
          displayText={'Select a template...'}
          options={templateKeys.map((path) => {
            return templates[path];
          })}
          onSelected={(sel) =>
            act('PRG_template', {
              name: sel,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};
