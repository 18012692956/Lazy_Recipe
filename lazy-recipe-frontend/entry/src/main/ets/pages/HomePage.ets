import { ApiService } from '../common/ApiService';
import { Preferences } from '../model/Preferences';
import { IngredientsMap, IngredientCategory, SubIngredientCategory } from '../model/IngredientsMap';
import router from '@ohos.router';

@Entry
@Component
export struct HomePage {
  @State categoryList: IngredientCategory[] = [];
  @State tastes: string[] = [];
  @State styles: string[] = [];

  @State selectedIngredients: string[] = [];
  @State selectedTaste: string = '';
  @State selectedStyle: string = '';

  @State expandedCategories: Set<string> = new Set();
  @State expandedSubcategories: Set<string> = new Set();

  private categoryDisplayMap: Record<string, string> = {
    'MEAT': '🥩 肉类',
    'VEGETABLE': '🥬 蔬菜',
    'STAPLE': '🍚 主食',
    'SEAFOOD': '🦐 水产',
    'EGG_DAIRY': '🥚 蛋奶',
    'BEAN_PRODUCT': '🫘 豆制品'
  };

  async aboutToAppear() {
    const rawMap: IngredientsMap = await ApiService.getIngredients();

    this.categoryList = Object.keys(rawMap).map((key: string): IngredientCategory => {
      return {
        category: key,
        subcategories: rawMap[key]
      };
    });

    const prefs: Preferences = await ApiService.getPreferences();
    this.tastes = prefs.tastes;
    this.styles = prefs.styles;
  }

  toggleCategory(category: string) {
    const newSet = new Set(this.expandedCategories);
    newSet.has(category) ? newSet.delete(category) : newSet.add(category);
    this.expandedCategories = newSet;
  }

  toggleSubcategory(subcategoryKey: string) {
    const newSet = new Set(this.expandedSubcategories);
    newSet.has(subcategoryKey) ? newSet.delete(subcategoryKey) : newSet.add(subcategoryKey);
    this.expandedSubcategories = newSet;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Column() {
          Text('懒人食谱助手')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Text('发现美食，享受生活')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 8, color: '#08000000', offsetY: 2 })

      Scroll() {
        Column() {
          // 选择食材标题
          Row() {
            Text('📦 选择食材')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            if (this.selectedIngredients.length > 0) {
              Text(`已选 ${this.selectedIngredients.length} 项`)
                .fontSize(14)
                .fontColor('#FF6B6B')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#FFE5E5')
                .borderRadius(12)
                .margin({ left: 12 })
            }
          }
          .width('100%')
          .margin({ top: 20, bottom: 12 })

          // 食材分类
          ForEach(this.categoryList, (catItem: IngredientCategory) => {
            Column() {
              // 大类标题
              Row() {
                Text(this.expandedCategories.has(catItem.category) ? '▼' : '▶')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ right: 10 })

                Text(this.categoryDisplayMap[catItem.category] ?? catItem.category)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 8 })
              .shadow({ radius: 4, color: '#08000000', offsetY: 2 })
              .onClick(() => this.toggleCategory(catItem.category))

              // 子类列表
              if (this.expandedCategories.has(catItem.category)) {
                Column() {
                  ForEach(catItem.subcategories, (subcat: SubIngredientCategory) => {
                    Column() {
                      // 子类标题
                      Row() {
                        Text(this.expandedSubcategories.has(`${catItem.category}-${subcat.subcategory}`) ? '▼' : '▶')
                          .fontSize(14)
                          .fontColor('#999999')
                          .margin({ right: 8 })

                        Text(subcat.subcategory)
                          .fontSize(16)
                          .fontColor('#666666')
                      }
                      .width('100%')
                      .padding({ left: 32, top: 12, bottom: 12, right: 16 })
                      .backgroundColor('#F8F9FA')
                      .borderRadius(8)
                      .margin({ top: 4 })
                      .onClick(() => this.toggleSubcategory(`${catItem.category}-${subcat.subcategory}`))

                      // 食材列表
                      if (this.expandedSubcategories.has(`${catItem.category}-${subcat.subcategory}`)) {
                        Column() {
                          ForEach(subcat.ingredients, (item: string) => {
                            Row() {
                              Checkbox()
                                .select(this.selectedIngredients.includes(item))
                                .selectedColor('#FF6B6B')
                                .onChange((value: boolean) => {
                                  if (value) {
                                    this.selectedIngredients.push(item);
                                  } else {
                                    this.selectedIngredients = this.selectedIngredients.filter(i => i !== item);
                                  }
                                })

                              Text(item)
                                .fontSize(15)
                                .fontColor('#333333')
                                .margin({ left: 12 })
                            }
                            .width('100%')
                            .padding({ left: 52, top: 8, bottom: 8, right: 16 })
                          })
                        }
                        .width('100%')
                        .backgroundColor('#FAFBFC')
                        .borderRadius(8)
                        .margin({ top: 4, left: 16, right: 4 })
                      }
                    }
                    .width('100%')
                  })
                }
                .width('100%')
                .margin({ bottom: 8 })
              }
            }
            .width('100%')
          })

          // 口味选择（已改为 Flex）
          Text('🌶️ 选择口味')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .margin({ top: 32, bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.tastes, (t: string) => {
              Text(t)
                .fontSize(16)
                .fontColor(this.selectedTaste === t ? '#FFFFFF' : '#666666')
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .backgroundColor(this.selectedTaste === t ? '#FF6B6B' : '#FFFFFF')
                .borderRadius(20)
                .border({ width: 1, color: this.selectedTaste === t ? '#FF6B6B' : '#DDDDDD' })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.selectedTaste = this.selectedTaste === t ? '' : t;
                })
            })
          }
          .width('100%')

          // 菜系选择（已改为 Flex）
          Text('🥘 选择菜系')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .margin({ top: 24, bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.styles, (s: string) => {
              Text(s)
                .fontSize(16)
                .fontColor(this.selectedStyle === s ? '#FFFFFF' : '#666666')
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .backgroundColor(this.selectedStyle === s ? '#4ECDC4' : '#FFFFFF')
                .borderRadius(20)
                .border({ width: 1, color: this.selectedStyle === s ? '#4ECDC4' : '#DDDDDD' })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.selectedStyle = this.selectedStyle === s ? '' : s;
                })
            })
          }
          .width('100%')

          // 开始推荐按钮
          Button('开始推荐菜谱 🔍')
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF6B6B')
            .borderRadius(25)
            .margin({ top: 32, bottom: 32 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/RecommendPage',
                params: {
                  ingredients: this.selectedIngredients,
                  taste: this.selectedTaste,
                  style: this.selectedStyle
                }
              });
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}