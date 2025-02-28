import { useBackend, useLocalState } from '../backend';
import { Button, Dimmer, Icon, LabeledList, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const PersonalCrafting = (props, context) => {
  const { act, data } = useBackend(context);
  const { busy, display_craftable_only, display_compact } = data;
  const crafting_recipes = data.crafting_recipes || {};
  // Sort everything into flat categories
  const categories = [];
  const recipes = [];
  for (let category of Object.keys(crafting_recipes)) {
    const subcategories = crafting_recipes[category];
    if ('has_subcats' in subcategories) {
      for (let subcategory of Object.keys(subcategories)) {
        if (subcategory === 'has_subcats') {
          continue;
        }
        // Push category
        categories.push({
          name: subcategory,
          category,
          subcategory,
        });
        // Push recipes
        const _recipes = subcategories[subcategory];
        for (let recipe of _recipes) {
          recipes.push({
            ...recipe,
            category: subcategory,
          });
        }
      }
      continue;
    }
    // Push category
    categories.push({
      name: category,
      category,
    });
    // Push recipes
    const _recipes = crafting_recipes[category];
    for (let recipe of _recipes) {
      recipes.push({
        ...recipe,
        category,
      });
    }
  }
  // Sort out the tab state
  const [tab, setTab] = useLocalState(context, 'tab', categories[0]?.name);
  const shownRecipes = recipes.filter((recipe) => recipe.category === tab);
  return (
    <Window title="Создание" width={700} height={700}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={1}>
            <Section fill title="Категории">
              <Tabs vertical>
                {categories.map((category) => (
                  <Tabs.Tab
                    height={2}
                    key={category.name}
                    selected={category.name === tab}
                    onClick={() => {
                      setTab(category.name);
                      act('set_category', {
                        category: category.category,
                        subcategory: category.subcategory,
                      });
                    }}>
                    {category.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow={5}>
            <Section
              fill
              title="Рецепты"
              buttons={
                <>
                  <Button.Checkbox
                    content="Компактно"
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  />
                  <Button.Checkbox
                    content="Только возможные"
                    checked={display_craftable_only}
                    onClick={() => act('toggle_recipes')}
                  />
                </>
              }>
              <Section fill scrollable>
                {busy ? (
                  <Dimmer fontSize="32px">
                    <Icon name="cog" spin={1} />
                    {' Создаём...'}
                  </Dimmer>
                ) : (
                  <CraftingList craftables={shownRecipes} />
                )}
              </Section>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CraftingList = (props, context) => {
  const { craftables = [] } = props;
  const { act, data } = useBackend(context);
  const { craftability = {}, display_compact, display_craftable_only } = data;
  return craftables.map((craftable) => {
    if (display_craftable_only && !craftability[craftable.ref]) {
      return null;
    }
    // Compact display
    if (display_compact) {
      return (
        <LabeledList.Item
          key={craftable.name}
          label={craftable.name}
          className="candystripe"
          buttons={
            <Button
              icon="cog"
              content="Создать"
              disabled={!craftability[craftable.ref]}
              tooltip={
                craftable.tool_text && 'Инструменты: ' + craftable.tool_text
              }
              tooltipPosition="left"
              onClick={() =>
                act('make', {
                  recipe: craftable.ref,
                })
              }
            />
          }>
          {craftable.req_text}
        </LabeledList.Item>
      );
    }
    // Full display
    return (
      <Section
        key={craftable.name}
        title={craftable.name}
        level={2}
        buttons={
          <Button
            icon="cog"
            content="Создать"
            disabled={!craftability[craftable.ref]}
            onClick={() =>
              act('make', {
                recipe: craftable.ref,
              })
            }
          />
        }>
        <LabeledList>
          {!!craftable.req_text && (
            <LabeledList.Item label="Требуется">
              {craftable.req_text}
            </LabeledList.Item>
          )}
          {!!craftable.catalyst_text && (
            <LabeledList.Item label="Катализатор">
              {craftable.catalyst_text}
            </LabeledList.Item>
          )}
          {!!craftable.tool_text && (
            <LabeledList.Item label="Инструменты">
              {craftable.tool_text}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
    );
  });
};
