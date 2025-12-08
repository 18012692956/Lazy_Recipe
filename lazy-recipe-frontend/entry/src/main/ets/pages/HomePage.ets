import { ApiService } from '../common/ApiService';
import { IngredientsMap } from '../model/IngredientsMap';
import { Preferences } from '../model/Preferences';
import router from '@ohos.router';

interface CategoryItem {
  key: string;
  value: string[];
}

@Entry
@Component
export struct HomePage {

  // 原始数据结构
  private ingredientsMap: IngredientsMap = {
    meat: [],
    vegetables: [],
    staple: []
  };

  // ArkTS 安全的可遍历结构
  @State categoryList: CategoryItem[] = [];

  @State tastes: string[] = [];
  @State styles: string[] = [];

  @State selectedIngredients: string[] = [];
  @State selectedTaste: string = "";
  @State selectedStyle: string = "";

  async aboutToAppear() {
    // 1. 获取后端数据
    this.ingredientsMap = await ApiService.getIngredients();

    // 2. 转换为 ArkTS 可遍历结构
    this.categoryList = [
      { key: "肉类", value: this.ingredientsMap.meat },
      { key: "蔬菜", value: this.ingredientsMap.vegetables },
      { key: "主食", value: this.ingredientsMap.staple }
    ];

    // 3. 获取口味 + 菜系
    const prefs: Preferences = await ApiService.getPreferences();
    this.tastes = prefs.tastes;
    this.styles = prefs.styles;
  }

  build() {
    Scroll() {
      Column() {
        Text("懒人食谱助手").fontSize(26).fontWeight(FontWeight.Bold)

        // ---------- 食材分类 ----------
        ForEach(this.categoryList, (cat: CategoryItem) => {
          Column() {
            Text(cat.key)
              .fontSize(20)
              .margin({ top: 10 })

            ForEach(cat.value, (item: string) => {
              Row() {
                Toggle({
                  type: ToggleType.Checkbox,
                  isOn: this.selectedIngredients.includes(item)
                })
                  .onChange((value: boolean) => {
                    if (value) {
                      this.selectedIngredients.push(item);
                    } else {
                      this.selectedIngredients =
                        this.selectedIngredients.filter(i => i !== item);
                    }
                  })

                Text(item)
                  .fontSize(16)
                  .margin({ left: 8 })
              }
              .margin({ top: 6 })
            })
          }
        })

        // ---------- 口味 ----------
        Text("选择口味").fontSize(20).margin({ top: 20 })
        ForEach(this.tastes, (t: string) => {
          Row() {
            // 左侧圆点图标，用 Circle 组件模拟 Radio
            Circle()
              .width(20)
              .height(20)
              .strokeWidth(2)
              .stroke(Color.Black)
              .backgroundColor(
                this.selectedTaste === t ? Color.Black : Color.White
              )
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
        Text("选择菜系").fontSize(20).margin({ top: 20 })
        ForEach(this.styles, (s: string) => {
          Row() {
            Circle()
              .width(20)
              .height(20)
              .strokeWidth(2)
              .stroke(Color.Black)
              .backgroundColor(
                this.selectedStyle === s ? Color.Black : Color.White
              )
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
        Button("推荐菜谱")
          .margin({ top: 30 })
          .onClick(() => {
            router.pushUrl({
              url: "pages/RecommendPage",
              params: {
                ingredients: this.selectedIngredients as string[],
                taste: this.selectedTaste as string,
                style: this.selectedStyle as string
              }
            });
          })
      }
      .width('100%')
      .padding(20)
    }
  }
}
