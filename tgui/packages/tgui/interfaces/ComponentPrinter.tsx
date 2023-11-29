import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Material, MaterialAmount, MaterialFormatting, Materials, MATERIAL_KEYS } from './common/Materials';
import { Window } from '../layouts';
import { Box, Button, Input, Section, Stack, Tabs } from '../components';

const CATEGORY_ALL = 'All';

const searchFor = (searchText) =>
  createSearch(searchText, ([_, thing]) => thing.name + thing.description);

const getCategory = (category: string[]) => {
  return category[0] === 'Circuitry' ? category[1] : category[0];
};

type Design = {
  name: string;
  description: string;
  materials: Record<keyof typeof MATERIAL_KEYS, number>;
  categories: string[];
};

type ComponentPrinterData = {
  designs: Record<string, Design>;
  materials: Material[];
};

const canProduce = (
  designMaterials: Design['materials'],
  storedMaterials: Material[]
) => {
  for (const material of storedMaterials) {
    const amountNeeded = designMaterials[material.name];

    if (amountNeeded && amountNeeded > material.amount) {
      return false;
    }
  }

  return true;
};

const MaterialCost = (props: { materials: Design['materials'] }) => {
  return (
    <Stack>
      {Object.entries(props.materials).map(([material, amount]) => {
        return (
          <Stack.Item key={material} mr={1}>
            <MaterialAmount
              name={material as keyof typeof MATERIAL_KEYS}
              amount={amount}
              formatting={MaterialFormatting.Locale}
              style={{
                transform: 'scale(0.75) translate(0%, 10%)',
              }}
            />
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

export const ComponentPrinter = (props) => {
  const { act, data } = useBackend<ComponentPrinterData>();
  const { materials, designs, SHEET_MATERIAL_AMOUNT } = data;

  const [currentCategory, setCurrentCategory] = useLocalState(
    context,
    'category',
    CATEGORY_ALL
  );
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Window title="Component Printer" width={900} height={700}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Materials">
              <Materials
                materials={data.materials || []}
                onEject={(ref, amount) => {
                  act('remove_mat', {
                    ref: ref,
                    amount: amount,
                  });
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Section title="Categories" fill>
                  <Tabs vertical fill>
                    {Object.values(data.designs)
                      .reduce<string[]>(
                        (categories, design) => {
                          const category = getCategory(design.categories);
                          if (categories.indexOf(category) === -1) {
                            return [category, ...categories];
                          } else {
                            return categories;
                          }
                        },
                        [CATEGORY_ALL]
                      )
                      .sort()
                      .map((category) => {
                        return (
                          <Tabs.Tab
                            key={category}
                            onClick={() => setCurrentCategory(category)}
                            selected={category === currentCategory}
                            fluid>
                            {category}
                          </Tabs.Tab>
                        );
                      })}
                  </Tabs>
                </Section>
              </Stack.Item>

              <Stack.Item basis="100%">
                <Section title="Parts">
                  <Stack vertical>
                    <Stack.Item>
                      <Input
                        placeholder="Search..."
                        autoFocus
                        fluid
                        value={searchText}
                        onInput={(_, value) => setSearchText(value)}
                      />
                    </Stack.Item>

                    {Object.entries(data.designs)
                      .filter(
                        ([_, design]) =>
                          currentCategory === CATEGORY_ALL ||
                          design.categories.indexOf(currentCategory) !== -1
                      )
                      .filter(searchFor(searchText))
                      .map(([designId, design]) => {
                        return (
                          <Stack.Item key={designId}>
                            <Section
                              title={design.name}
                              buttons={
                                <Button
                                  onClick={() => {
                                    act('print', {
                                      designId,
                                    });
                                  }}
                                  disabled={
                                    !canProduce(
                                      design.materials,
                                      data.materials
                                    )
                                  }
                                  px={1.5}>
                                  Print
                                </Button>
                              }>
                              <Box inline width="100%">
                                {design.description}
                              </Box>
                              <MaterialCost materials={design.materials} />
                            </Section>
                          </Stack.Item>
                        );
                      })}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type RecipeProps = {
  design: Design;
  available: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const Recipe = (props: RecipeProps) => {
  const { act } = useBackend<ComponentPrinterData>();
  const { design, available, SHEET_MATERIAL_AMOUNT } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0)
  );

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}>
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            available={available}
          />
        }>
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('print', { designId: design.id, amount: 1 })
          }>
          <div className="FabricatorRecipe__Icon">
            <Box
              width={'32px'}
              height={'32px'}
              className={classes(['design32x32', design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>
    </div>
  );
};
