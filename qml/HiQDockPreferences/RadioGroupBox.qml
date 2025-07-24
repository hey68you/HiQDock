import QtQuick 2.5

Rectangle {

    id: topLevelRadioBox;
    property ListModel radioButtonValues: undefined;

    signal newOptionSelected(int selectedIndex);

    color: "transparent"

    Row {
        Repeater {
            model: radioButtonValues
            CheckBox {
                id: chckBoxRadioBottomPos

                labelString: radioButtonValues.get(model.index).label;
                selected:    radioButtonValues.get(model.index).isSelected;
                isRadioType: true;
                width:       topLevelRadioBox.width/radioButtonValues.count + 5;

                onRadioClicked: {
//                    console.log("chckBoxRadioBottomPos clicked: " + model.index + ": " + radioButtonValues.count)

                    if (radioButtonValues.get(model.index).isSelected == false)
                    {
                        for (var i=0; i<radioButtonValues.count; i++)
                        {
                            //clear all other buttons
                            radioButtonValues.get(i).isSelected = false;
                        }

                        radioButtonValues.get(model.index).isSelected = true;
                        newOptionSelected(model.index);

                    }
                }
            }
        }
    }
}
