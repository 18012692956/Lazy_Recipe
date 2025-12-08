import { ApiService } from '../common/ApiService';
import { Recipe } from '../model/Recipe';
import { RecommendRequest } from '../model/RecommendRequest';
import router from '@ohos.router';

@Entry
@Component
export struct RecommendPage {

  @State recipes: Recipe[] = [];

  private navParams: RecommendRequest = {
    ingredients: [],
    taste: "",
    style: ""
  };

  aboutToAppear() {
    // HarmonyOS NEXT 标准方法：获取路由参数
    const params = router.getParams();

    if (params) {
      this.navParams = params as RecommendRequest;
    }

    this.loadRecipes();
  }

  private async loadRecipes() {
    this.recipes = await ApiService.recommend(
      this.navParams.ingredients,
      this.navParams.taste,
      this.navParams.style
    );
  }

  build() {
    Column() {
      if (this.recipes.length === 0) {
        Text("正在加载推荐菜谱…")
          .fontSize(20)
          .margin({ top: 20 });
      } else {
        List() {
          ForEach(this.recipes, (r: Recipe) => {
            ListItem() {
              Column() {
                Text(r.title)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold);

                Text("用料：" + r.ingredients.join("、"))
                  .fontSize(16)
                  .margin({ top: 6 });

                Text(`口味：${r.taste} ｜ 菜系：${r.style}`)
                  .fontSize(16)
                  .margin({ top: 4 });
              }
              .padding(12)
            }
          }, (r: Recipe) => r.id.toString()) // ForEach 必须有 key
        }
      }
      Button("返回")
        .margin({ bottom: 10 })
        .onClick(() => {
          router.back();
        })
    }
    .padding(20)
  }
}
