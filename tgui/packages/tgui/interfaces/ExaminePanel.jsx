// THIS IS A SKYRAT UI FILE
import { useState } from 'react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { ByondUi, Section, Stack, Tabs, Link } from 'tgui-core/components';
import { Window } from '../layouts';

const formatURLs = (text) => {
  if (!text) return;
  const parts = [];
  let regex = /https?:\/\/[^\s/$.?#].[^\s]*/gi;
  let lastIndex = 0;

  text.replace(regex, (url, index) => {
    parts.push(text.substring(lastIndex, index));
    parts.push(
      <a
        style={{
          color: '#0591e3',
          'text-decoration': 'none',
        }}
        href={url}
      >
        {url}
      </a>,
    );
    lastIndex = index + url.length;
    return url;
  });

  parts.push(text.substring(lastIndex));

  return <div>{parts}</div>;
};

export const ExaminePanel = (props) => {
  const [tabIndex, setTabIndex] = useState(1);
  const [lowerTabIndex, setLowerTabIndex] = useState(1);
  const { act, data } = useBackend();
  const {
    character_name,
    obscured,
    flavor_text,
    headshot,
    ooc_notes,
    ooc_link,
    ooc_embrace_pref,
    ooc_ghoul_pref,
    ooc_bond_pref,
    ooc_escalation_pref
  } = data;
  return (
    <Window
      title={character_name + "'s Examine Panel"}
      width={900}
      height={670}
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item width="30%">
            <Section height="310px" title="Headshot">
              <img
                src={
                  tabIndex === 2
                    ? resolveAsset(headshot)
                    : resolveAsset(headshot)
                }
                height="250px"
                width="250px"
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Tabs fluid>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                <Section fitted title={'Flavor Text'} />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                <Section fitted title={'Character Link'} />
              </Tabs.Tab>
            </Tabs>
            {tabIndex === 1 && (
              <Section
                style={{ 'overflow-y': 'scroll' }}
                fitted
                preserveWhitespace
                minHeight="50%"
                maxHeight="50%"
                fontSize="14px"
                lineHeight="1.7"
                textIndent="3em"
              >
                {formatURLs(flavor_text)}
              </Section>
            )}
            {tabIndex === 2 && (
              <Section
                style={{ 'overflow-y': 'scroll' }}
                fitted
                preserveWhitespace
                minHeight="50%"
                maxHeight="50%"
                fontSize="14px"
                lineHeight="1.7"
                textIndent="3em"
              >
                Character Link: {formatURLs(ooc_link)}
              </Section>
            )}
            <Tabs fluid>
              <Tabs.Tab
                selected={lowerTabIndex === 1}
                onClick={() => setLowerTabIndex(1)}
              >
                <Section fitted title={'OOC Preferences'} />
              </Tabs.Tab>
              <Tabs.Tab
                selected={lowerTabIndex === 2}
                onClick={() => setLowerTabIndex(2)}
              >
                <Section fitted title={'OOC Notes'} />
              </Tabs.Tab>
            </Tabs>
            {lowerTabIndex === 1 && (
              <Section
                style={{ 'overflow-y': 'scroll' }}
                preserveWhitespace
                fitted
                minHeight="35%"
                maxHeight="35%"
                fontSize="14px"
                lineHeight="1.5">
                <Stack direction = "column">
                  <Stack.Item> </Stack.Item>
                  <Stack.Item>
                    Embracing Preference: {ooc_embrace_pref}
                  </Stack.Item>
                  <Stack.Item> </Stack.Item>
                  <Stack.Item>
                    Ghouling Preference: {ooc_ghoul_pref}
                  </Stack.Item>
                  <Stack.Item> </Stack.Item>
                  <Stack.Item>
                    Blood-bonding Preference: {ooc_bond_pref}
                  </Stack.Item>
                  <Stack.Item> </Stack.Item>
                  <Stack.Item>
                    Unprovoked Violence: {ooc_escalation_pref}
                  </Stack.Item>
                </Stack>
              </Section>
            )}
            {lowerTabIndex === 2 && (
              <Section
                style={{ 'overflow-y': 'scroll' }}
                preserveWhitespace
                fitted
                minHeight="35%"
                maxHeight="35%"
                fontSize="14px"
                lineHeight="1.5"
              >
                <Stack.Item>{formatURLs(ooc_notes)}</Stack.Item>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
