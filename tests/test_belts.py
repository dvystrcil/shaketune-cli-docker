from conftest import SAMPLES


def test_belts(gradio_predict, assert_png):
    result = gradio_predict(
        files=[SAMPLES / "belts_a.csv", SAMPLES / "belts_b.csv"],
        gt="belts",
        kinematics_b="corexy",
    )
    assert_png(result)
