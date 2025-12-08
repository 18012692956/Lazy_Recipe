import { ApiService } from '../common/ApiService';
import { Preferences } from '../model/Preferences';
import { IngredientsMap, IngredientCategory, SubIngredientCategory } from '../model/IngredientsMap';
import router from '@ohos.router';

@Entry
@Component
export struct HomePage {
  @State categoryList: IngredientCategory[] = []; // ✅ 修改为结构化数组
  @State tastes: string[] = [];
  @State styles: string[] = [];

  @State selectedIngredients: string[] = [];
  @State selectedTaste: string = '';
  @State selectedStyle: string = '';

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

    // ✅ 转换成 ArkTS 可遍历结构
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

  build() {
    Scroll() {
      Column() {
        Text('懒人食谱助手').fontSize(26).fontWeight(FontWeight.Bold)

        // ---------- 食材分类 ----------
        ForEach(this.categoryList, (catItem: IngredientCategory) => {
          Column() {
            Text(this.categoryDisplayMap[catItem.category] ?? catItem.category)
              .fontSize(20)
              .margin({ top: 10 })

            ForEach(catItem.subcategories, (subcat: SubIngredientCategory) => {
              Column() {
                Text(subcat.subcategory)
                  .fontSize(18)
                  .margin({ top: 6, bottom: 2 })

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
                  .margin({ top: 4 })
                })
              }
            })
          }
        })

        // ---------- 口味 ----------
        Text('选择口味').fontSize(20).margin({ top: 20 })
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
        Text('选择菜系').fontSize(20).margin({ top: 20 })
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

        // ---------- 跳转 ----------
        Button('推荐菜谱')
          .margin({ top: 30 })
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
