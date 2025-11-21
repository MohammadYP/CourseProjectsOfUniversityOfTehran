#include "NNaccelerator.hpp"

const int IMG_NUM = 1;
const char *folder_path = "../img bins/";

void read_img(float tensor_input_1[1][3][32][32], char* name)
{
    char* temp_name[60];
    strcpy(temp_name, folder_path);
    strcat(temp_name, name);

    FILE *f = fopen(temp_name, "rb");

    if (f == NULL) {
        perror("Error opening tensor file");
        return;
    }
    fread(tensor_input_1, sizeof(float), 1 * 3 * 32 * 32, f);
    fclose(f);
}

void predict(float tensor_input_1[1][3][32][32])
{
    float tensor_39[1][10];

    entry(tensor_input_1, tensor_39);
    int i;
    for (int i = 0; i < 10; i++)
        printf("%.2f\n", tensor_39[0][i]);
}

void fetch_file_names(char img_list[IMG_NUM][40])
{

    DIR *dir = opendir(folder_path);

    struct dirent *element;
    int counter = 0;
    while ((element = readdir(dir)) != NULL) {
        // Skip "." and ".."
        if (strcmp(element->d_name, ".") == 0 || strcmp(element->d_name, "..") == 0)
            continue;
        strcpy(img_list[counter], element->d_name);
        // printf("%s\n", element->d_name);
        counter++;
    }

    closedir(dir);
}

void NNaccelerator::operation(){
    sc_lv<8> controlReg,StatusReg,Probability,Sickness;

    float tensor_input_1[1][3][32][32];
    char img_list[IMG_NUM][40];

    if (write == sc_logic_1){
        if(addressIn == "00000000"){
            controlReg = dataIn;
        }
    }
    if(read == sc_logic_1){
        if(addressIn == "00000000"){
            dataOut = controlReg;
        }
        else if (addressIn == "00000100"){
            dataOut = StatusReg;
            StatusReg = "00000000";
        }
        else if (addressIn == "00001000"){
            dataOut = Probibility;
        }
        else if (addressIn == "00001100"){
            dataOut = Sickness;
        }
    }
    if (controlReg == "00000001"){
        //start Opereation
        
        fetch_file_names(img_list);
        read_img(tensor_input_1, img_list[i]);
        float tensor_39[1][10];
        entry(tensor_input_1, tensor_39);
        float tempprobability = 0;
        int prob = 0;
        int tempSickness = 0;
        for (int i = 0; i < 10;i++){
            if(tempprobability < tensor_39[1][i]){
                tempprobability = tensor_39[1][i];
                tempSickness = i+1;
            }
        }
        tempprobability = tempprobability *100;
        prob = (int) tempprobability;
        Probability = prob;
        Sickness = tempSickness;
        StatusReg = "00000001";
    }
}