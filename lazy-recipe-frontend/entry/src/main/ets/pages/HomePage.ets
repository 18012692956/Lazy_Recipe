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

  // ✅ 折叠状态管理
  @State expandedCategories: Set<string> = new Set();
  @State expandedSubcategories: Set<string> = new Set();

  private categoryDisplayMap: Record<string, string> = {
    'MEAT': '肉类',
    'VEGETABLE': '蔬菜',
    'STAPLE': '主食',
    'SEAFOOD': '水产',
    'EGG_DAIRY': '蛋奶',
    'BEAN_PRODUCT': '豆制品'
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

  // ✅ 切换大类展开/收起
  toggleCategory(category: string) {
    const newSet = new Set(this.expandedCategories);
    if (newSet.has(category)) {
      newSet.delete(category);
    } else {
      newSet.add(category);
    }
    this.expandedCategories = newSet;
  }

  // ✅ 切换子类展开/收起
  toggleSubcategory(subcategoryKey: string) {
    const newSet = new Set(this.expandedSubcategories);
    if (newSet.has(subcategoryKey)) {
      newSet.delete(subcategoryKey);
    } else {
      newSet.add(subcategoryKey);
    }
    this.expandedSubcategories = newSet;
  }

  build() {
    Scroll() {
      Column() {
        Text('懒人食谱助手')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('选择食材')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 30, bottom: 10 })

        // ---------- 食材分类（多级可折叠） ----------
        ForEach(this.categoryList, (catItem: IngredientCategory) => {
          Column() {
            // 大类标题（可点击折叠）
            Row() {
              Text(this.expandedCategories.has(catItem.category) ? '▼' : '▶')
                .fontSize(18)
                .margin({ right: 8 })

              Text(this.categoryDisplayMap[catItem.category] ?? catItem.category)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .margin({ top: 10 })
            .onClick(() => {
              this.toggleCategory(catItem.category);
            })

            // 子类列表（根据展开状态显示）
            if (this.expandedCategories.has(catItem.category)) {
              Column() {
                ForEach(catItem.subcategories, (subcat: SubIngredientCategory) => {
                  Column() {
                    // 子类标题（可点击折叠）
                    Row() {
                      Text(this.expandedSubcategories.has(`${catItem.category}-${subcat.subcategory}`) ? '▼' : '▶')
                        .fontSize(16)
                        .margin({ right: 6 })

                      Text(subcat.subcategory)
                        .fontSize(18)
                    }
                    .width('100%')
                    .padding({ left: 20, top: 8, bottom: 8 })
                    .backgroundColor('#fafafa')
                    .margin({ top: 4 })
                    .onClick(() => {
                      this.toggleSubcategory(`${catItem.category}-${subcat.subcategory}`);
                    })

                    // 具体食材列表（根据展开状态显示）
                    if (this.expandedSubcategories.has(`${catItem.category}-${subcat.subcategory}`)) {
                      Column() {
                        ForEach(subcat.ingredients, (item: string) => {
                          Row() {
                            Toggle({
                              type: ToggleType.Checkbox,
                              isOn: this.selectedIngredients.includes(item)
                            })
                              .onChange((value: boolean) => {
                                if (value) {
                                  this.selectedIngredients.push(item);
                                } else {
                                  this.selectedIngredients = this.selectedIngredients.filter(i => i !== item);
                                }
                              })

                            Text(item)
                              .fontSize(16)
                              .margin({ left: 8 })
                          }
                          .width('100%')
                          .padding({ left: 40, top: 4, bottom: 4 })
                        })
                      }
                      .width('100%')
                      .margin({ top: 4, bottom: 4 })
                    }
                  }
                  .width('100%')
                })
              }
              .width('100%')
              .padding({ left: 10 })
            }
          }
          .width('100%')
        })

        // ---------- 口味 ----------
        Text('选择口味')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 30, bottom: 10 })

        ForEach(this.tastes, (t: string) => {
          Row() {
            Circle()
              .width(20)
              .height(20)
              .strokeWidth(2)
              .stroke(Color.Black)
              .backgroundColor(this.selectedTaste === t ? Color.Black : Color.White)
              .onClick(() => {
                this.selectedTaste = t;
              })

            Text(t)
              .fontSize(18)
              .margin({ left: 10 })
          }
          .margin({ top: 6 })
        })

        // ---------- 菜系 ----------
        Text('选择菜系')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 20, bottom: 10 })

        ForEach(this.styles, (s: string) => {
          Row() {
            Circle()
              .width(20)
              .height(20)
              .strokeWidth(2)
              .stroke(Color.Black)
              .backgroundColor(this.selectedStyle === s ? Color.Black : Color.White)
              .onClick(() => {
                this.selectedStyle = s;
              })

            Text(s)
              .fontSize(18)
              .margin({ left: 10 })
          }
          .margin({ top: 6 })
        })

        // ---------- 推荐按钮 ----------
        Button('推荐菜谱')
          .width('100%')
          .height(50)
          .fontSize(18)
          .margin({ top: 30, bottom: 20 })
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
      .padding(20)
    }
  }
}