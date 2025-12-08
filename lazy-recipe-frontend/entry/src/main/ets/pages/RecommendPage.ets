import { ApiService } from '../common/ApiService';
import { Recipe } from '../model/Recipe';
import { RecommendRequest } from '../model/Request';
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

  private async toggleFavorite(recipe: Recipe) {
    await ApiService.updateFavorite(recipe.id); // ⬅️ 添加 API 请求
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
              Row() {
                Column() {
                  Text(r.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                  Text(`难度：${r.difficulty}｜耗时：${r.timeMinutes}`)
                    .fontSize(16)
                    .margin({ top: 4 })
                }
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/DetailPage',
                    params: r
                  });
                })
                Blank().layoutWeight(1)
                Image(r.favorite ? $r("app.media.heart_filled") : $r("app.media.heart_unfilled")) // ❤️ 图标
                  .width(24)
                  .height(24)
                  .onClick(() => this.toggleFavorite(r))
              }
              .padding(12)
            }
          }, (r: Recipe) => r.id.toString())
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
