import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { BooleanLike, classes } from 'common/react';
import { useBackend } from '../backend';
import { Button, Dimmer, Icon, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

type RawRecipe = {
  name: string;
  ref: string;
  req_text: string;
  catalyst_text: string;
  tool_text: string;
};

type RawData = {
  // Dynamic data
  busy: BooleanLike | null;
  category: string;
  subcategory: string;
  display_craftable_only: BooleanLike;
  display_compact: BooleanLike;
  craftability: Record<string, BooleanLike>;
  // Static data
  crafting_recipes: Record<
    string,
    // That's the weirdest piece of type I had to write in my life.
    // Yes, that's how subcategories are sent here.
    RawRecipe[] | (Record<string, RawRecipe[]> & { has_subcats: 1 })
  >;
};

export const PersonalCrafting = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    busy,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
  } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const [pages, setPages] = useLocalState('pages', 1);
  const DEFAULT_CAT_CRAFTING = Object.keys(CATEGORY_ICONS_CRAFTING)[1];
  const DEFAULT_CAT_COOKING = Object.keys(CATEGORY_ICONS_COOKING)[1];
  const [activeCategory, setCategory] = useLocalState<string>(
    'category',
    Object.keys(craftability).length
      ? 'Can Make'
      : mode === MODE.cooking
        ? DEFAULT_CAT_COOKING
        : DEFAULT_CAT_CRAFTING
  );
  const [activeType, setFoodType] = useLocalState(
    'foodtype',
    Object.keys(craftability).length ? 'Can Make' : data.foodtypes[0]
  );
  const material_occurences = flow([
    sortBy<Material>((material) => -material.occurences),
  ])(data.material_occurences);
  const [activeMaterial, setMaterial] = useLocalState(
    'material',
    material_occurences[0].atom_id
  );
  const [tabMode, setTabMode] = useLocalState('tabMode', 0);
  const searchName = createSearch(searchText, (item: Recipe) => item.name);
  let recipes = flow([
    filter<Recipe>(
      (recipe) =>
        // Show selected category only
        isCategorySelected(data, recipe) &&
        // If craftable only is selected, then filter by craftability
        (!display_craftable_only || recipe.craftable)
    ),
    sortBy<Recipe>((recipe) => [-recipe.craftable, recipe.name]),
  ])(recipes);

  return (
    <Window title="Crafting Menu" width={700} height={700}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="150px">
            <Section fill scrollable title="Category">
              {groups.map((group) => (
                <Section key={group.name} title={group.name}>
                  {group.categories.map((category) => (
                    <Button
                      key={category.name}
                      fluid
                      color="transparent"
                      selected={isCategorySelected(data, category)}
                      onClick={() =>
                        act('set_category', {
                          category: category.dm_category,
                          subcategory: category.dm_subcategory,
                        })
                      }>
                      {category.name}
                    </Button>
                  ))}
                </Section>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow={3}>
            <Section
              fill
              title="Recipes"
              buttons={
                <>
                  <Button.Checkbox
                    content="Compact"
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  />
                  <Button.Checkbox
                    content="Craftable Only"
                    checked={display_craftable_only}
                    onClick={() => act('toggle_recipes')}
                  />
                </>
              }>
              <Section fill scrollable>
                {busy ? (
                  <Dimmer fontSize="32px">
                    <Icon name="cog" spin={1} />
                    {' Crafting...'}
                  </Dimmer>
                ) : (
                  <CraftingList
                    recipes={shownRecipes}
                    compact={Boolean(display_compact)}
                  />
                )}
              </Section>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialContent = (props) => {
  const { atom_id, occurences } = props;
  const { data } = useBackend<Data>();
  const name = data.atom_data[atom_id - 1].name;
  const mode = data.mode;
  return (
    <Stack>
      <Stack.Item>
        <Box
          verticalAlign="middle"
          inline
          ml={-1.5}
          mr={-0.5}
          className={classes([
            mode ? 'cooking32x32' : 'crafting32x32',
            'a' + atom_id,
          ])}
        />
      </Stack.Item>
      <Stack.Item
        height="32px"
        lineHeight="32px"
        grow
        style={{
          'text-transform': 'capitalize',
          'overflow': 'hidden',
          'text-overflow': 'ellipsis',
          'white-space': 'nowrap',
        }}>
        {name}
      </Stack.Item>
      <Stack.Item height="32px" lineHeight="32px">
        {occurences}
      </Stack.Item>
    </Stack>
  ) as any;
};

const CraftingList = (props: CraftingListProps, context) => {
  const { recipes = [], compact } = props;
  const { act } = useBackend<RawData>(context);

  if (compact) {
    return <CompactCraftingList recipes={recipes} />;
  }

  return recipes.map((recipe) => (
    <div
      key={recipe.ref}
      className={classes([
        'PersonalCraftingGridItem',
        recipe.craftable && 'PersonalCraftingGridItem--craftable',
      ])}
      onClick={() => {
        if (recipe.craftable) {
          act('make', {
            recipe: recipe.ref,
          });
        }
      }}>
      <div className="PersonalCraftingGridItem__content">
        <div className="PersonalCraftingGridItem__name">{recipe.name}</div>
        {!!recipe.req_text &&
          recipe.req_text.split(', ').map((req, i) => (
            <div key={req + i} className="PersonalCraftingGridItem__prereq">
              {req}
            </div>
          ))}
        {!!recipe.catalyst_text && (
          <div className="PersonalCraftingGridItem__extra">
            <b>Catalyst:</b> {recipe.catalyst_text}
          </div>
        )}
        {!!recipe.tool_text && (
          <div className="PersonalCraftingGridItem__extra">
            <b>Tools:</b> {recipe.tool_text}
          </div>
        )}
        <div className="PersonalCraftingGridItem__craftability">
          {recipe.craftable ? 'Craft' : 'Uncraftable'}
        </div>
      </div>
    </div>
  )) as any;
};

const RecipeContentCompact = ({ item, craftable, busy, mode }) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section>
      <Stack my={-0.75}>
        <Stack.Item>
          <Box className={item.icon} />
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              <Box style={{ 'text-transform': 'capitalize' }} color={'gray'}>
                {Array.from(
                  Object.keys(item.reqs).map((atom_id) => {
                    const name = data.atom_data[(atom_id as any) - 1]?.name;
                    const is_reagent =
                      data.atom_data[(atom_id as any) - 1]?.is_reagent;
                    const amount = item.reqs[atom_id];
                    return is_reagent
                      ? `${name}\xa0${amount}u`
                      : amount > 1
                        ? `${name}\xa0${amount}x`
                        : name;
                  })
                ).join(', ')}

                {item.chem_catalysts &&
                  ', ' +
                    Object.keys(item.chem_catalysts)
                      .map((atom_id) => {
                        const name = data.atom_data[(atom_id as any) - 1]?.name;
                        const is_reagent =
                          data.atom_data[(atom_id as any) - 1]?.is_reagent;
                        const amount = item.chem_catalysts[atom_id];
                        return is_reagent
                          ? `${name}\xa0${amount}u`
                          : amount > 1
                            ? `${name}\xa0${amount}x`
                            : name;
                      })
                      .join(', ')}

                {item.tool_paths &&
                  ', ' +
                    item.tool_paths
                      .map((item) => data.atom_data[(item as any) - 1]?.name)
                      .join(', ')}
                {item.machinery &&
                  ', ' +
                    item.machinery
                      .map((item) => data.atom_data[(item as any) - 1]?.name)
                      .join(', ')}
                {item.structures &&
                  ', ' +
                    item.structures
                      .map((item) => data.atom_data[(item as any) - 1]?.name)
                      .join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!item.non_craftable ? (
                <Box>
                  {!!item.tool_behaviors && (
                    <Tooltip
                      content={'Tools: ' + item.tool_behaviors.join(', ')}>
                      <Icon p={1} name="screwdriver-wrench" />
                    </Tooltip>
                  )}
                  <Button
                    my={0.3}
                    lineHeight={2.5}
                    align="center"
                    content="Make"
                    disabled={!craftable || busy}
                    icon={
                      busy
                        ? 'circle-notch'
                        : mode === MODE.cooking
                          ? 'utensils'
                          : 'hammer'
                    }
                    iconSpin={busy ? 1 : 0}
                    onClick={() =>
                      act('make', {
                        recipe: item.ref,
                      })
                    }
                  />
                </Box>
              ) : (
                item.steps && (
                  <Tooltip
                    content={item.steps.map((step) => (
                      <Box key={step}>{step}</Box>
                    ))}>
                    <Box fontSize={1.5} p={1}>
                      <Icon name="circle-question-o" />
                    </Box>
                  </Tooltip>
                )
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RecipeContent = ({ item, craftable, busy, mode, diet }) => {
  const { act } = useBackend<Data>();
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box width={'64px'} height={'64px'} mr={1}>
            <Box
              style={{
                'transform': 'scale(1.5)',
              }}
              m={'16px'}
              className={item.icon}
            />
          </Table.Cell>
        </tr>
      ))}
    </table>
  );
};

const AtomContent = ({ atom_id, amount }) => {
  const { data } = useBackend<Data>();
  const name = data.atom_data[atom_id - 1]?.name;
  const is_reagent = data.atom_data[atom_id - 1]?.is_reagent;
  const mode = data.mode;
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes([
          mode ? 'cooking32x32' : 'crafting32x32',
          'a' + atom_id,
        ])}
      />
      <Box inline verticalAlign="middle">
        {name}
        {is_reagent ? `\xa0${amount}u` : amount > 1 && `\xa0${amount}x`}
      </Box>
    </Box>
  ) as any;
};

const ToolContent = ({ tool }) => {
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes(['crafting32x32', tool.replace(/ /g, '')])}
      />
      <Box inline verticalAlign="middle">
        {tool}
      </Box>
    </Box>
  ) as any;
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color={'gray'}>{title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};
